import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/sensors/sensor_station.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/light.dart';
import 'package:result_dart/result_dart.dart';

/// A phone in sensor mode paired with this one.
class SensorPhone {
  final String id;
  final String name;
  final String address;
  final String code;
  // Plant ids, and groups of plants as their negated ids
  final Set<int> links;
  final double? azimuth;

  const SensorPhone({
    required this.id,
    required this.name,
    required this.address,
    required this.code,
    this.links = const {},
    this.azimuth,
  });

  SensorPhone copyWith({Set<int>? links, double? azimuth, String? address}) =>
      SensorPhone(
        id: id,
        name: name,
        address: address ?? this.address,
        code: code,
        links: links ?? this.links,
        azimuth: azimuth ?? this.azimuth,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'code': code,
        'links': links.toList(),
        'azimuth': azimuth,
      };

  factory SensorPhone.fromJson(Map<String, dynamic> json) => SensorPhone(
        id: json['id'],
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        code: json['code'] ?? '',
        links: {for (dynamic id in json['links'] ?? []) (id as num).toInt()},
        azimuth: (json['azimuth'] as num?)?.toDouble(),
      );
}

/// What a sensor phone measured near a plant.
class LightSummary {
  final SensorPhone phone;
  final SensorReading? last;
  final double? todayDli;
  // Average of the last complete days with readings
  final double? averageDli;
  final List<LightSample> lastDay;

  const LightSummary({
    required this.phone,
    this.last,
    this.todayDli,
    this.averageDli,
    this.lastDay = const [],
  });
}

/// The phones in sensor mode paired with this one, their readings and the
/// plants each one measures.
class SensorPhoneService {
  static const String _phonesKey = 'sensor_phones';

  final AppDatabase _db;
  final UserSettingRepository _settings;
  final CollectionRepository _collectionRepository;
  final Future<Map<String, dynamic>> Function(String address, String code,
      {DateTime? since}) _ask;
  final Logger _log = Logger('SensorPhoneService');

  SensorPhoneService({
    required AppDatabase db,
    required UserSettingRepository userSettingRepository,
    required CollectionRepository collectionRepository,
    Future<Map<String, dynamic>> Function(String address, String code,
            {DateTime? since})?
        ask,
  })  : _db = db,
        _settings = userSettingRepository,
        _collectionRepository = collectionRepository,
        _ask = ask ?? SensorProtocol.ask;

  Future<List<SensorPhone>> phones() async {
    String saved =
        (await _settings.getOrDefault(_phonesKey, '')).getOrDefault('');
    if (saved.isEmpty) return [];
    try {
      return [
        for (dynamic p in json.decode(saved) as List) SensorPhone.fromJson(p)
      ];
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<SensorPhone> phones) => _settings.put(
      _phonesKey, json.encode([for (SensorPhone p in phones) p.toJson()]));

  /// Pairs the sensor phone at [address] that shows [code], and brings its
  /// readings.
  Future<Result<SensorPhone>> add(String address, String code) async {
    try {
      Map<String, dynamic> answer = await _ask(address.trim(), code.trim());
      if (answer['ok'] != true) {
        return Failure(const SensorPhoneException('wrong code'));
      }
      SensorPhone phone = SensorPhone(
        id: answer['device'],
        name: answer['name'] ?? address,
        address: address.trim(),
        code: code.trim(),
        azimuth: (answer['azimuth'] as num?)?.toDouble(),
      );
      List<SensorPhone> all =
          (await phones()).where((p) => p.id != phone.id).toList()..add(phone);
      await _save(all);
      await _store(phone.id, answer);
      return Success(phone);
    } catch (e) {
      return Failure(SensorPhoneException(e.toString()));
    }
  }

  Future<void> remove(String id) async =>
      _save((await phones()).where((p) => p.id != id).toList());

  Future<void> setLinks(String id, Set<int> links) async => _save([
        for (SensorPhone p in await phones())
          p.id == id ? p.copyWith(links: links) : p
      ]);

  /// Brings the new readings of every paired phone that can be reached.
  /// Returns how many phones answered.
  Future<int> sync() async {
    List<SensorPhone> all = await phones();
    int answered = 0;
    List<SensorPhone> updated = [];
    for (SensorPhone phone in all) {
      try {
        SensorReading? last = await (_db.select(_db.sensorReadings)
              ..where((r) => r.device.equals(phone.id))
              ..orderBy([(r) => OrderingTerm.desc(r.time)])
              ..limit(1))
            .getSingleOrNull();
        Map<String, dynamic> answer =
            await _ask(phone.address, phone.code, since: last?.time);
        if (answer['ok'] == true) {
          await _store(phone.id, answer);
          answered++;
          double? azimuth = (answer['azimuth'] as num?)?.toDouble();
          updated.add(phone.copyWith(azimuth: azimuth));
          continue;
        }
      } catch (e) {
        _log.fine('${phone.name} not reachable: $e');
      }
      updated.add(phone);
    }
    if (answered > 0) await _save(updated);
    return answered;
  }

  Future<void> _store(String device, Map<String, dynamic> answer) async {
    List<dynamic> readings = answer['readings'] ?? [];
    await _db.batch((batch) {
      batch.insertAll(
        _db.sensorReadings,
        [
          for (dynamic r in readings)
            SensorReadingsCompanion.insert(
              device: device,
              time: DateTime.fromMillisecondsSinceEpoch((r[0] as num).toInt()),
              lux: Value((r[1] as num?)?.toDouble()),
              pressure: Value((r[2] as num?)?.toDouble()),
              temperature: Value((r[3] as num?)?.toDouble()),
            )
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// The plants each phone measures, directly or through a group.
  Future<Map<String, Set<int>>> linkedPlants() async {
    List<SensorPhone> all = await phones();
    if (all.isEmpty) return {};
    Map<int, Set<int>> groups =
        (await _collectionRepository.getPlantsByCollection()).getOrDefault({});
    return {
      for (SensorPhone p in all)
        p.id: {
          for (int id in p.links)
            if (id > 0) id else ...?groups[-id]
        }
    };
  }

  /// What the phone linked to [plantId] measured, if any.
  Future<LightSummary?> summaryOf(int plantId) async {
    Map<String, Set<int>> linked = await linkedPlants();
    SensorPhone? phone = (await phones())
        .where((p) => linked[p.id]?.contains(plantId) ?? false)
        .firstOrNull;
    if (phone == null) return null;
    return summary(phone);
  }

  /// What [phone] measured: its last reading, the light of today and of
  /// the last days.
  Future<LightSummary> summary(SensorPhone phone, {DateTime? now}) async {
    DateTime at = now ?? DateTime.now();
    DateTime today = DateTime(at.year, at.month, at.day);
    List<SensorReading> readings = await (_db.select(_db.sensorReadings)
          ..where((r) =>
              r.device.equals(phone.id) &
              r.time.isBiggerOrEqualValue(
                  today.subtract(const Duration(days: 4))))
          ..orderBy([(r) => OrderingTerm.asc(r.time)]))
        .get();
    List<LightSample> samples = [
      for (SensorReading r in readings)
        if (r.lux != null) LightSample(r.time, r.lux!)
    ];
    Map<DateTime, double> daily = dailyLightIntegrals(samples);
    // Complete days only: today is still going on
    List<double> past = [
      for (MapEntry<DateTime, double> e in daily.entries)
        if (e.key.isBefore(today)) e.value
    ];
    DateTime dayAgo = at.subtract(const Duration(hours: 24));
    return LightSummary(
      phone: phone,
      last: readings.isEmpty ? null : readings.last,
      todayDli: daily[today],
      averageDli: past.isEmpty
          ? null
          : past.reduce((a, b) => a + b) / past.length,
      lastDay: samples.where((s) => s.time.isAfter(dayAgo)).toList(),
    );
  }
}

class SensorPhoneException implements Exception {
  final String message;

  const SensorPhoneException(this.message);

  @override
  String toString() => message;
}
