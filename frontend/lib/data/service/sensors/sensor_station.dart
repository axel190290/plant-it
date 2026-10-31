import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:uuid/uuid.dart';

/// The sensors of this phone, read by its Android code.
class PhoneSensors {
  static const MethodChannel _channel = MethodChannel('plant_it/sensors');

  const PhoneSensors();

  Future<Map<String, bool>> available() async =>
      Map<String, bool>.from(await _channel.invokeMethod('available') ?? {});

  Future<void> start({bool dimScreen = true}) =>
      _channel.invokeMethod('start', {'dimScreen': dimScreen});

  Future<void> stop() => _channel.invokeMethod('stop');

  /// The last values: lux, pressure (hPa), azimuth (degrees) and the
  /// battery temperature (°C). Each may be null.
  Future<Map<String, double?>> read() async {
    Map<dynamic, dynamic> values = await _channel.invokeMethod('read') ?? {};
    return {
      for (String key in ['lux', 'pressure', 'azimuth', 'batteryTemperature'])
        key: (values[key] as num?)?.toDouble()
    };
  }
}

/// How a phone in sensor mode and the phone of the user talk on the local
/// network: one line of JSON each way over TCP. The request carries the
/// pairing code shown by the sensor phone.
class SensorProtocol {
  static const int port = 8742;

  /// The answer of a sensor phone to [request].
  static Future<Map<String, dynamic>> answer(
    Map<String, dynamic> request, {
    required AppDatabase db,
    required String device,
    required String name,
    required String code,
    double? azimuth,
  }) async {
    if (request['code'] != code) {
      return {'ok': false, 'error': 'code'};
    }
    // At most the last week, from the requested time
    DateTime week = DateTime.now().subtract(const Duration(days: 7));
    int since = (request['since'] as num?)?.toInt() ?? 0;
    DateTime from = DateTime.fromMillisecondsSinceEpoch(since);
    if (from.isBefore(week)) from = week;
    List<SensorReading> readings = await (db.select(db.sensorReadings)
          ..where((r) => r.device.equals(device) & r.time.isBiggerThanValue(from))
          ..orderBy([(r) => OrderingTerm.asc(r.time)])
          ..limit(5000))
        .get();
    return {
      'ok': true,
      'device': device,
      'name': name,
      'azimuth': azimuth,
      'readings': [
        for (SensorReading r in readings)
          [r.time.millisecondsSinceEpoch, r.lux, r.pressure, r.temperature]
      ],
    };
  }

  /// Asks a sensor phone at [address] for its readings after [since].
  static Future<Map<String, dynamic>> ask(String address, String code,
      {DateTime? since}) async {
    Socket socket = await Socket.connect(address, port,
        timeout: const Duration(seconds: 5));
    try {
      socket.write('${json.encode({
            'code': code,
            'since': since?.millisecondsSinceEpoch ?? 0,
          })}\n');
      await socket.flush();
      String answer = await utf8.decoder
          .bind(socket)
          .transform(const LineSplitter())
          .first
          .timeout(const Duration(seconds: 20));
      return json.decode(answer);
    } finally {
      socket.destroy();
    }
  }
}

/// This phone in sensor mode: it measures every few seconds, keeps an
/// average every five minutes and answers the phones paired with it.
class SensorStation extends ChangeNotifier {
  static const Duration _sampleEvery = Duration(seconds: 30);
  static const Duration _saveEvery = Duration(minutes: 5);
  static const String _idKey = 'sensor_station_id';
  static const String _codeKey = 'sensor_station_code';
  static const String _nameKey = 'sensor_station_name';

  final AppDatabase _db;
  final UserSettingRepository _settings;
  final PhoneSensors _sensors;

  SensorStation({
    required AppDatabase db,
    required UserSettingRepository userSettingRepository,
    PhoneSensors sensors = const PhoneSensors(),
  })  : _db = db,
        _settings = userSettingRepository,
        _sensors = sensors;

  Timer? _timer;
  ServerSocket? _server;
  final List<Map<String, double?>> _pending = [];
  DateTime _lastSave = DateTime.now();

  bool _running = false;
  Map<String, double?> _current = {};
  Map<String, bool> _available = {};
  String _id = '';
  String _code = '';
  String _name = '';
  List<String> _addresses = [];
  int _saved = 0;

  bool get running => _running;
  Map<String, double?> get current => _current;
  Map<String, bool> get available => _available;
  String get code => _code;
  String get name => _name;
  List<String> get addresses => _addresses;
  int get saved => _saved;

  Future<String> _setting(String key, String Function() create) async {
    String value = (await _settings.getOrDefault(key, '')).getOrDefault('');
    if (value.isEmpty) {
      value = create();
      await _settings.put(key, value);
    }
    return value;
  }

  /// Loads the identity of this phone, made the first time.
  Future<void> load({required String defaultName}) async {
    _id = await _setting(_idKey, () => const Uuid().v4());
    _code = await _setting(
        _codeKey, () => (Random.secure().nextInt(900000) + 100000).toString());
    _name = await _setting(_nameKey, () => defaultName);
    _available = await _sensors.available();
    _addresses = [
      for (NetworkInterface i
          in await NetworkInterface.list(type: InternetAddressType.IPv4))
        for (InternetAddress a in i.addresses)
          if (!a.isLoopback) a.address
    ];
    notifyListeners();
  }

  Future<void> rename(String name) async {
    _name = name.trim().isEmpty ? _name : name.trim();
    await _settings.put(_nameKey, _name);
    notifyListeners();
  }

  Future<void> start() async {
    if (_running) return;
    await _sensors.start();
    _server = await ServerSocket.bind(InternetAddress.anyIPv4,
        SensorProtocol.port,
        shared: true);
    _server!.listen(_serve);
    _lastSave = DateTime.now();
    _timer = Timer.periodic(_sampleEvery, (_) => _sample());
    _running = true;
    notifyListeners();
    await _sample();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _server?.close();
    _server = null;
    await _sensors.stop();
    await _save();
    _running = false;
    notifyListeners();
  }

  Future<void> _sample() async {
    _current = await _sensors.read();
    _pending.add(_current);
    if (DateTime.now().difference(_lastSave) >= _saveEvery) await _save();
    notifyListeners();
  }

  /// Saves the average of the samples since the last save.
  Future<void> _save() async {
    if (_pending.isEmpty) return;
    double? average(String key) {
      List<double> values =
          _pending.map((s) => s[key]).whereType<double>().toList();
      return values.isEmpty
          ? null
          : values.reduce((a, b) => a + b) / values.length;
    }

    await _db.into(_db.sensorReadings).insert(
          SensorReadingsCompanion.insert(
            device: _id,
            time: DateTime.now(),
            lux: Value(average('lux')),
            pressure: Value(average('pressure')),
            temperature: Value(average('batteryTemperature')),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    _pending.clear();
    _lastSave = DateTime.now();
    _saved++;
  }

  void _serve(Socket socket) {
    utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .first
        .timeout(const Duration(seconds: 10))
        .then((line) async {
      Map<String, dynamic> answer = await SensorProtocol.answer(
        json.decode(line),
        db: _db,
        device: _id,
        name: _name,
        code: _code,
        azimuth: _current['azimuth'],
      );
      socket.write('${json.encode(answer)}\n');
      await socket.flush();
    }).catchError((_) {}).whenComplete(socket.destroy);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _server?.close();
    super.dispose();
  }
}
