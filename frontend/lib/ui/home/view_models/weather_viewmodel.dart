import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:result_dart/result_dart.dart';

/// The local weather and the alerts for the outdoor plants, shown on the
/// home page.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    required WeatherService weatherService,
    required PlantRepository plantRepository,
    required SpeciesCareRepository speciesCareRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required UserSettingRepository userSettingRepository,
  })  : _speciesCareValueRepository = speciesCareValueRepository,
        _userSettingRepository = userSettingRepository,
        _weatherService = weatherService,
        _plantRepository = plantRepository,
        _speciesCareRepository = speciesCareRepository {
    load = Command.createAsyncNoParam(() async {
      await _load();
    }, initialValue: null);
  }

  final WeatherService _weatherService;
  final PlantRepository _plantRepository;
  final SpeciesCareRepository _speciesCareRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final UserSettingRepository _userSettingRepository;

  late final Command<void, void> load;

  bool _hasPlace = false;
  Weather? _weather;
  List<WeatherAlert> _alerts = [];

  bool get hasPlace => _hasPlace;
  Weather? get weather => _weather;
  List<WeatherAlert> get alerts => _alerts;

  Future<void> _load() async {
    _hasPlace = await _weatherService.currentPlace() != null;
    Result<Weather> weather = await _weatherService.getWeather();
    _weather = weather.getOrNull();
    List<WeatherAlert> alerts = _weather == null
        ? []
        : weatherAlerts(_weather!, await _outdoorPlants(_weather!.season));
    Set<String> dismissed = await _dismissed();
    DateTime today = DateTime.now();
    _alerts = alerts.where((a) => !dismissed.contains(a.key(today))).toList();
    notifyListeners();
  }

  Future<Set<String>> _dismissed() async {
    String saved = (await _userSettingRepository.getOrDefault(
            UserSettingsKeys.dismissedWeatherAlerts.key, ""))
        .getOrDefault("");
    return saved.split('\n').where((k) => k.isNotEmpty).toSet();
  }

  /// Hides [alert] until it changes: another day, other plants or another
  /// kind of alert are shown again.
  Future<void> dismiss(WeatherAlert alert) async {
    DateTime now = DateTime.now();
    String key = alert.key(now);
    _alerts = _alerts.where((a) => a.key(now) != key).toList();
    notifyListeners();
    // Alerts of past days will not come back: forget them
    String today = WeatherAlert(type: alert.type, plants: const [])
        .key(now)
        .split('|')
        .first;
    Set<String> dismissed = (await _dismissed())
        .where((k) => k.split('|').first.compareTo(today) >= 0)
        .toSet()
      ..add(key);
    await _userSettingRepository.put(
        UserSettingsKeys.dismissedWeatherAlerts.key, dismissed.join('\n'));
  }

  Future<List<OutdoorPlant>> _outdoorPlants(Season season) async {
    List<Plant> plants = (await _plantRepository.getAll()).getOrDefault([]);
    List<OutdoorPlant> outdoor = [];
    for (Plant plant in plants) {
      if (plant.location != PlantLocation.outdoor) continue;
      Result<SpeciesCareData> care =
          await _speciesCareRepository.get(plant.species);
      Map<String, CareValue> values =
          (await _speciesCareValueRepository.getBySpeciesKeyed(plant.species))
              .getOrDefault({});
      outdoor.add(OutdoorPlant(plant.name, care.getOrNull()?.tempMin,
          care.getOrNull()?.tempMax, wateringDays(values, season)));
    }
    return outdoor;
  }
}
