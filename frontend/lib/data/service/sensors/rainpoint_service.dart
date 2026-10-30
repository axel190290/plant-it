import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_client.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

/// The RainPoint devices of the user, the plants each one is linked to,
/// and the waterings of the linked water timers recorded as events.
class RainPointService {
  // Readings are not asked again before this, not to overload the cloud
  static const Duration _cacheFor = Duration(minutes: 5);

  final RainPointClient _client;
  final UserSettingRepository _settings;
  final EventRepository _eventRepository;
  final EventTypeRepository _eventTypeRepository;
  final Logger _log = Logger('RainPointService');

  List<RainPointDevice>? _devices;
  DateTime? _devicesAt;

  RainPointService({
    required RainPointClient client,
    required UserSettingRepository userSettingRepository,
    required EventRepository eventRepository,
    required EventTypeRepository eventTypeRepository,
  })  : _client = client,
        _settings = userSettingRepository,
        _eventRepository = eventRepository,
        _eventTypeRepository = eventTypeRepository;

  Future<String> _get(UserSettingsKeys key) async =>
      (await _settings.getOrDefault(key.key, '')).getOrDefault('');

  Future<bool> isConfigured() async =>
      (await _get(UserSettingsKeys.rainPointEmail)).isNotEmpty &&
      (await _get(UserSettingsKeys.rainPointPassword)).isNotEmpty;

  /// The saved account: email, country code and app.
  Future<(String, String, String)> account() async => (
        await _get(UserSettingsKeys.rainPointEmail),
        await _get(UserSettingsKeys.rainPointAreaCode),
        (await _get(UserSettingsKeys.rainPointApp)).isEmpty
            ? RainPointClient.rainPointApp
            : await _get(UserSettingsKeys.rainPointApp),
      );

  /// Logs in with a new account and keeps it if it works. An empty
  /// password keeps the saved one.
  Future<Result<List<RainPointDevice>>> connect({
    required String email,
    required String password,
    required String areaCode,
    required String appCode,
  }) async {
    String pass = password.isEmpty
        ? await _get(UserSettingsKeys.rainPointPassword)
        : password;
    Result<(String, DateTime)> login = await _client.login(
        email: email.trim(),
        password: pass,
        areaCode: areaCode.trim(),
        appCode: appCode);
    if (login.isError()) return Failure(login.exceptionOrNull()!);
    await _settings.put(UserSettingsKeys.rainPointEmail.key, email.trim());
    await _settings.put(UserSettingsKeys.rainPointPassword.key, pass);
    await _settings.put(
        UserSettingsKeys.rainPointAreaCode.key, areaCode.trim());
    await _settings.put(UserSettingsKeys.rainPointApp.key, appCode);
    await _saveToken(login.getOrThrow());
    return devices(refresh: true);
  }

  /// Forgets the account and the links.
  Future<void> disconnect() async {
    for (UserSettingsKeys key in [
      UserSettingsKeys.rainPointEmail,
      UserSettingsKeys.rainPointPassword,
      UserSettingsKeys.rainPointToken,
      UserSettingsKeys.rainPointTokenExpires,
      UserSettingsKeys.rainPointLinks,
      UserSettingsKeys.rainPointWaterings,
    ]) {
      await _settings.remove(key.key);
    }
    _devices = null;
  }

  Future<void> _saveToken((String, DateTime) token) async {
    await _settings.put(UserSettingsKeys.rainPointToken.key, token.$1);
    await _settings.put(UserSettingsKeys.rainPointTokenExpires.key,
        token.$2.millisecondsSinceEpoch.toString());
  }

  /// A valid token, logging in again only when the saved one expired:
  /// each login closes the session of the RainPoint app.
  Future<Result<String>> _token({bool force = false}) async {
    String token = await _get(UserSettingsKeys.rainPointToken);
    int? expires =
        int.tryParse(await _get(UserSettingsKeys.rainPointTokenExpires));
    bool valid = token.isNotEmpty &&
        expires != null &&
        DateTime.fromMillisecondsSinceEpoch(expires)
            .isAfter(DateTime.now().add(const Duration(hours: 1)));
    if (valid && !force) return Success(token);
    (String, String, String) account = await this.account();
    Result<(String, DateTime)> login = await _client.login(
      email: account.$1,
      password: await _get(UserSettingsKeys.rainPointPassword),
      areaCode: account.$2,
      appCode: account.$3,
    );
    if (login.isError()) return Failure(login.exceptionOrNull()!);
    await _saveToken(login.getOrThrow());
    return Success(login.getOrThrow().$1);
  }

  /// The devices and their last readings.
  Future<Result<List<RainPointDevice>>> devices({bool refresh = false}) async {
    if (!refresh &&
        _devices != null &&
        DateTime.now().difference(_devicesAt!) < _cacheFor) {
      return Success(_devices!);
    }
    if (!await isConfigured()) return Success(const []);
    String app = (await account()).$3;
    Result<String> token = await _token();
    if (token.isError()) return Failure(token.exceptionOrNull()!);
    Result<List<RainPointDevice>> result =
        await _client.devices(token.getOrThrow(), app);
    Object? error = result.exceptionOrNull();
    if (error is RainPointException && error.expiredToken) {
      token = await _token(force: true);
      if (token.isError()) return Failure(token.exceptionOrNull()!);
      result = await _client.devices(token.getOrThrow(), app);
    }
    if (result.isSuccess()) {
      _devices = result.getOrThrow();
      _devicesAt = DateTime.now();
    }
    return result;
  }

  /// The plants each device is linked to, by device key.
  Future<Map<String, Set<int>>> links() async {
    String saved = await _get(UserSettingsKeys.rainPointLinks);
    if (saved.isEmpty) return {};
    try {
      Map<String, dynamic> map = json.decode(saved);
      return {
        for (MapEntry<String, dynamic> e in map.entries)
          e.key: {for (dynamic id in e.value as List) (id as num).toInt()}
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> setLinks(String deviceKey, Set<int> plantIds) async {
    Map<String, Set<int>> all = await links();
    if (plantIds.isEmpty) {
      all.remove(deviceKey);
    } else {
      all[deviceKey] = plantIds;
    }
    await _settings.put(
        UserSettingsKeys.rainPointLinks.key,
        json.encode({
          for (MapEntry<String, Set<int>> e in all.entries)
            e.key: e.value.toList()
        }));
  }

  /// The devices linked to [plantId], with their readings. Empty when no
  /// account is set or the cloud cannot be reached.
  Future<List<RainPointDevice>> devicesOf(int plantId) async {
    Map<String, Set<int>> linked = await links();
    if (!linked.values.any((ids) => ids.contains(plantId))) return const [];
    Result<List<RainPointDevice>> all = await devices();
    if (all.isError()) {
      _log.warning(all.exceptionOrNull());
      return const [];
    }
    return all
        .getOrThrow()
        .where((d) => linked[d.key]?.contains(plantId) ?? false)
        .toList();
  }

  /// Records as watering events the waterings the linked water timers did
  /// since they were last checked. Returns how many events were made.
  Future<int> recordWaterings() async {
    Map<String, Set<int>> linked = await links();
    if (linked.isEmpty) return 0;
    Result<List<RainPointDevice>> all = await devices();
    if (all.isError()) return 0;
    Map<String, int> seen = {};
    try {
      String saved = await _get(UserSettingsKeys.rainPointWaterings);
      if (saved.isNotEmpty) {
        seen = (json.decode(saved) as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {}
    EventType? watering = (await _eventTypeRepository.getAll())
        .getOrDefault([])
        .where((t) => t.name == 'watering')
        .firstOrNull;
    if (watering == null) return 0;

    int made = 0;
    bool changed = false;
    for (RainPointDevice device in all.getOrThrow()) {
      RainPointReading? reading = device.reading;
      Set<int>? plants = linked[device.key];
      DateTime? time = reading?.eventTime;
      if (device.kind != RainPointKind.valve ||
          plants == null ||
          reading == null ||
          time == null ||
          reading.watering == true ||
          (reading.lastWaterLiters ?? 0) <= 0) {
        continue;
      }
      int at = time.millisecondsSinceEpoch;
      int? last = seen[device.key];
      if (last != null && at <= last) continue;
      seen[device.key] = at;
      changed = true;
      // The first check only remembers the last watering
      if (last == null) continue;
      for (int plant in plants) {
        Result<int> event = await _eventRepository.insert(EventsCompanion(
          type: Value(watering.id),
          plant: Value(plant),
          date: Value(time.toLocal()),
          note: Value('RainPoint ${device.name}: '
              '${reading.lastWaterLiters!.toStringAsFixed(1)} l'),
        ));
        if (event.isSuccess()) made++;
      }
    }
    if (changed) {
      await _settings.put(
          UserSettingsKeys.rainPointWaterings.key, json.encode(seen));
    }
    return made;
  }
}
