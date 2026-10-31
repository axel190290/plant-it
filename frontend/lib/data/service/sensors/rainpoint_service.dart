import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_client.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
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
  final CollectionRepository _collectionRepository;
  final Logger _log = Logger('RainPointService');

  List<RainPointDevice>? _devices;
  DateTime? _devicesAt;

  RainPointService({
    required RainPointClient client,
    required UserSettingRepository userSettingRepository,
    required EventRepository eventRepository,
    required EventTypeRepository eventTypeRepository,
    required CollectionRepository collectionRepository,
  })  : _client = client,
        _collectionRepository = collectionRepository,
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

  /// What each device is linked to, by device key: plant ids, and groups
  /// of plants as their negated ids.
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

  /// Links a device to plants and to groups of plants, given as their
  /// negated ids.
  Future<void> setLinks(String deviceKey, Set<int> linked) async {
    Map<String, Set<int>> all = await links();
    if (linked.isEmpty) {
      all.remove(deviceKey);
    } else {
      all[deviceKey] = linked;
    }
    await _settings.put(
        UserSettingsKeys.rainPointLinks.key,
        json.encode({
          for (MapEntry<String, Set<int>> e in all.entries)
            e.key: e.value.toList()
        }));
  }

  /// The plants each device is linked to, directly or through a group.
  Future<Map<String, Set<int>>> linkedPlants() async {
    Map<String, Set<int>> all = await links();
    if (all.isEmpty) return {};
    Map<int, Set<int>> groups =
        (await _collectionRepository.getPlantsByCollection()).getOrDefault({});
    return {
      for (MapEntry<String, Set<int>> e in all.entries)
        e.key: {
          for (int id in e.value)
            if (id > 0) id else ...?groups[-id]
        }
    };
  }

  /// The devices linked to [plantId], with their readings. Empty when no
  /// account is set or the cloud cannot be reached.
  Future<List<RainPointDevice>> devicesOf(int plantId) async {
    Map<String, Set<int>> linked = await linkedPlants();
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

  /// Work mode of a water timer that mists instead of watering.
  static const int _mistMode = 2;

  /// Records as events the sessions the linked water timers did since they
  /// were last checked: waterings, and mistings as misting events. A
  /// session is noticed when what the timer reports of its last one (end
  /// time, liters, duration) changes; the mode is the one seen while it
  /// ran, watering when not seen. Returns how many events were made.
  Future<int> recordWaterings() async {
    Map<String, Set<int>> linked = await linkedPlants();
    if (linked.isEmpty) return 0;
    Result<List<RainPointDevice>> all = await devices();
    if (all.isError()) return 0;
    // By device: the last session seen and the mode of the running one
    Map<String, Map<String, dynamic>> state = {};
    try {
      String saved = await _get(UserSettingsKeys.rainPointWaterings);
      if (saved.isNotEmpty) {
        (json.decode(saved) as Map<String, dynamic>).forEach((key, value) {
          // Older versions kept only a time, which is read again
          if (value is Map<String, dynamic>) state[key] = value;
        });
      }
    } catch (_) {}
    List<EventType> types =
        (await _eventTypeRepository.getAll()).getOrDefault([]);
    EventType? typeFor(String name, SuggestionKind kind) =>
        types.where((t) => t.name == name).firstOrNull ??
        types.where((t) => isSuggestionEventType(t.name, kind)).firstOrNull;
    EventType? watering = typeFor('watering', SuggestionKind.watering);
    EventType? misting = typeFor('misting', SuggestionKind.misting) ?? watering;
    if (watering == null) return 0;

    int made = 0;
    bool changed = false;
    for (RainPointDevice device in all.getOrThrow()) {
      RainPointReading? reading = device.reading;
      Set<int>? plants = linked[device.key];
      if (device.kind != RainPointKind.valve ||
          plants == null ||
          reading == null) {
        continue;
      }
      Map<String, dynamic> seen = state[device.key] ?? {};
      if (reading.watering == true) {
        // Running: its mode tells a misting from a watering
        if ((reading.workMode ?? 0) > 0 && seen['mode'] != reading.workMode) {
          state[device.key] = {...seen, 'mode': reading.workMode};
          changed = true;
        }
        continue;
      }
      String signature = [
        reading.eventTime?.millisecondsSinceEpoch,
        reading.lastWaterLiters,
        reading.durationSeconds,
      ].join('|');
      if (signature == '||' || seen['last'] == signature) continue;
      String? previous = seen['last'];
      int mode = (seen['mode'] as num?)?.toInt() ?? 1;
      state[device.key] = {'last': signature};
      changed = true;
      // The first check only remembers the last session
      if (previous == null) continue;
      EventType type = mode == _mistMode ? misting! : watering;
      List<String> details = [
        if ((reading.lastWaterLiters ?? 0) > 0)
          '${reading.lastWaterLiters!.toStringAsFixed(1)} l',
        if ((reading.durationSeconds ?? 0) > 0)
          '${(reading.durationSeconds! / 60).round()} min',
      ];
      for (int plant in plants) {
        Result<int> event = await _eventRepository.insert(EventsCompanion(
          type: Value(type.id),
          plant: Value(plant),
          date: Value((reading.eventTime ?? DateTime.now()).toLocal()),
          note: Value(['RainPoint ${device.name}', ...details].join(' · ')),
        ));
        if (event.isSuccess()) made++;
      }
    }
    if (changed) {
      await _settings.put(
          UserSettingsKeys.rainPointWaterings.key, json.encode(state));
    }
    return made;
  }
}
