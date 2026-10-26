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

    ScheduleHints hints = readScheduleTexts(values, latitude);
    hints = hints.merge(await _askAi(values, hints, latitude));

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
