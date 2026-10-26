import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:result_dart/result_dart.dart';

/// Suggests reminders for a plant from the care of its species, the local
/// season and its location.
class ReminderSuggestionService {
  final SpeciesCareRepository _speciesCareRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final WeatherService _weatherService;
  final AiCareEstimator _aiCareEstimator;

  ReminderSuggestionService({
    required SpeciesCareRepository speciesCareRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required WeatherService weatherService,
    required AiCareEstimator aiCareEstimator,
  })  : _speciesCareRepository = speciesCareRepository,
        _speciesCareValueRepository = speciesCareValueRepository,
        _weatherService = weatherService,
        _aiCareEstimator = aiCareEstimator;

  Future<List<ReminderSuggestion>> suggest(Plant plant) async {
    SpeciesCareData? care =
        (await _speciesCareRepository.get(plant.species)).getOrNull();
    Map<String, CareValue> values =
        (await _speciesCareValueRepository.getBySpeciesKeyed(plant.species))
            .getOrDefault({});

    Weather? weather = (await _weatherService.getWeather()).getOrNull();
    double? latitude =
        weather?.latitude ?? (await _weatherService.currentPlace())?.latitude;

    // The texts are read only for what the schedule categories lack
    ScheduleHints read = ScheduleHints.fromValues(values)
        .merge(readScheduleTexts(values, latitude));
    ScheduleHints fromAi = await _askAi(values, read, latitude);
    ScheduleHints hints = read.merge(fromAi);
    values = {
      ...values,
      ...await _store(plant.species, values, read, fromAi),
    };

    return suggestReminders(
      today: DateTime.now(),
      plant: plant,
      care: care,
      values: values,
      season: weather?.season,
      latitude: latitude,
      hints: hints,
    );
  }

  /// Saves in the empty schedule categories what was read from the texts,
  /// so they are read only once and shown in the plant page. Returns the
  /// values saved.
  Future<Map<String, CareValue>> _store(
      int speciesId,
      Map<String, CareValue> values,
      ScheduleHints read,
      ScheduleHints fromAi) async {
    Map<String, CareValue> byRules = read.toValues();
    Map<String, CareValue> byAi = fromAi.toValues(estimated: true);
    Map<String, CareValue> found = {
      for (String key in {...byRules.keys, ...byAi.keys})
        if (values[key] == null) key: byRules[key] ?? byAi[key]!
    };
    if (found.isEmpty) {
      return {};
    }
    Result<void> saved =
        await _speciesCareValueRepository.saveByKeys(speciesId, found);
    return saved.isSuccess() ? found : {};
  }

  /// The AI reading of the texts the rules could not read, if configured.
  Future<ScheduleHints> _askAi(Map<String, CareValue> values,
      ScheduleHints hints, double? latitude) async {
    Map<String, String> unread = {
      if (hints.fertilizerQuantity == null && values['fertilizer'] != null)
        'fertilizer': values['fertilizer']!.text ?? '',
      if (hints.pruningMonth == null && values['pruning'] != null)
        'pruning': values['pruning']!.text ?? '',
      if ((hints.repottingYears == null || hints.repottingMonth == null) &&
          values['repotting'] != null)
        'repotting': values['repotting']!.text ?? '',
    }..removeWhere((key, text) => text.trim().isEmpty);
    if (unread.isEmpty) {
      return const ScheduleHints();
    }
    AiProvider provider = await _aiCareEstimator.configuredProvider();
    if (provider == AiProvider.none) {
      return const ScheduleHints();
    }
    Result<ScheduleHints> read = await _aiCareEstimator.interpretSchedule(
        provider, unread, (latitude ?? 0) < 0);
    return read.getOrDefault(const ScheduleHints());
  }
}
