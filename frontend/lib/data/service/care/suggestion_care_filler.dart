import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/repository/species_repository.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:result_dart/result_dart.dart';

/// Fills with the AI the care categories the reminder suggestions read.
class SuggestionCareFiller {
  /// Care values, by key, the reminder suggestions read.
  static const List<String> keys = [
    'watering_summer',
    'watering_winter',
    'misting_every',
    'fertilizer_every',
    'pruning_month',
    'repotting_years',
    'repotting_month',
    'common_pests',
  ];

  final AiCareEstimator _aiCareEstimator;
  final WeatherService _weatherService;
  final SpeciesRepository _speciesRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final Logger _log = Logger("SuggestionCareFiller");

  SuggestionCareFiller({
    required AiCareEstimator aiCareEstimator,
    required WeatherService weatherService,
    required SpeciesRepository speciesRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
  })  : _aiCareEstimator = aiCareEstimator,
        _weatherService = weatherService,
        _speciesRepository = speciesRepository,
        _speciesCareValueRepository = speciesCareValueRepository;

  Future<AiProvider> configuredProvider() =>
      _aiCareEstimator.configuredProvider();

  Future<bool> isAvailable() async =>
      await configuredProvider() != AiProvider.none;

  /// The AI estimate of the care of a species, with the months of the
  /// hemisphere of the chosen place.
  Future<Result<CareData>> estimate(Specy species) async {
    AiProvider provider = await _aiCareEstimator.configuredProvider();
    if (provider == AiProvider.none) {
      return Failure(Exception("No AI provider configured"));
    }
    return _aiCareEstimator.estimate(
        provider, species.scientificName, species.family,
        southernHemisphere: await _weatherService.southernHemisphere());
  }

  /// Saves the estimate of the categories of [speciesId] that have no
  /// value. Never fails: without AI or on error nothing is saved. Returns
  /// whether something was saved.
  Future<bool> fillMissing(int speciesId) async {
    Map<String, CareValue> values =
        (await _speciesCareValueRepository.getBySpeciesKeyed(speciesId))
            .getOrDefault({});
    List<String> missing = keys.where((k) => values[k] == null).toList();
    if (missing.isEmpty || !await isAvailable()) {
      return false;
    }
    Result<Specy> species = await _speciesRepository.get(speciesId);
    if (species.isError()) {
      return false;
    }
    Result<CareData> estimate = await this.estimate(species.getOrThrow());
    if (estimate.isError()) {
      _log.warning(estimate.exceptionOrNull());
      return false;
    }
    Map<String, CareValue> found = {
      for (String key in missing)
        if (estimate.getOrThrow().extra[key] != null)
          key: estimate.getOrThrow().extra[key]!
    };
    if (found.isEmpty) {
      return false;
    }
    Result<void> saved =
        await _speciesCareValueRepository.saveByKeys(speciesId, found);
    return saved.isSuccess();
  }
}
