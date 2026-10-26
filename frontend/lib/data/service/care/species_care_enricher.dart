import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/open_plantbook_client.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:result_dart/result_dart.dart';

/// Completes the care of an external species: first with the measured
/// values of Open Plantbook, then, only for the values still missing,
/// with an AI estimate. Every source used is recorded in [CareSources].
class SpeciesCareEnricher {
  final OpenPlantbookClient _openPlantbookClient;
  final AiCareEstimator _aiCareEstimator;
  final WeatherService _weatherService;
  final Logger _log = Logger("SpeciesCareEnricher");

  SpeciesCareEnricher({
    required OpenPlantbookClient openPlantbookClient,
    required AiCareEstimator aiCareEstimator,
    required WeatherService weatherService,
  })  : _openPlantbookClient = openPlantbookClient,
        _aiCareEstimator = aiCareEstimator,
        _weatherService = weatherService;

  /// Never fails: a source that is not configured or not reachable is
  /// skipped and the values it would give stay empty. Returns the basic
  /// care, the values of built-in care fields by key, and the sources used.
  Future<(SpeciesCareCompanion, Map<String, CareValue>, CareSources)> enrich({
    required String scientificName,
    String? family,
    required SpeciesCareCompanion care,
    Map<String, CareValue> extra = const {},
    required CareSources sources,
  }) async {
    Map<String, CareValue> values = Map.of(extra);

    if (await _openPlantbookClient.isConfigured()) {
      Result<CareData> plantbook =
          await _openPlantbookClient.getCare(scientificName);
      if (plantbook.isError()) {
        _log.info(plantbook.exceptionOrNull());
      } else {
        SpeciesCareCompanion before = care;
        int valuesBefore = values.length;
        care = _fillMissing(care, plantbook.getOrThrow().care);
        _fillMissingExtra(values, plantbook.getOrThrow().extra);
        if (_missingFields(before).length != _missingFields(care).length ||
            values.length != valuesBefore) {
          sources = sources.copyWith(care: CareSources.openPlantbook);
        }
      }
    }

    List<String> missing = _missingFields(care);
    bool missingExtra = [
      ...AiCareEstimator.numberFields,
      ...AiCareEstimator.textFields
    ].any((key) => !values.containsKey(key));
    if (missing.isEmpty && !missingExtra) {
      return (care, values, sources);
    }
    AiProvider provider = await _aiCareEstimator.configuredProvider();
    if (provider == AiProvider.none) {
      return (care, values, sources);
    }
    Result<CareData> estimate = await _aiCareEstimator.estimate(
        provider, scientificName, family,
        southernHemisphere: await _weatherService.southernHemisphere());
    if (estimate.isError()) {
      _log.warning(estimate.exceptionOrNull());
      return (care, values, sources);
    }
    care = _fillMissing(care, estimate.getOrThrow().care);
    int valuesBefore = values.length;
    _fillMissingExtra(values, estimate.getOrThrow().extra);
    List<String> estimated =
        missing.where((f) => !_missingFields(care).contains(f)).toList();
    if (estimated.isNotEmpty || values.length != valuesBefore) {
      sources = sources.copyWith(
        aiProvider: provider.key,
        aiFields: CareSources.groupFields(estimated),
      );
    }
    return (care, values, sources);
  }

  static void _fillMissingExtra(
      Map<String, CareValue> values, Map<String, CareValue> other) {
    other.forEach((key, value) {
      if (!values.containsKey(key) && !value.isEmpty) {
        values[key] = value;
      }
    });
  }

  static List<String> _missingFields(SpeciesCareCompanion care) {
    return [
      if (care.light.value == null) 'light',
      if (care.humidity.value == null) 'humidity',
      if (care.tempMin.value == null) 'tempMin',
      if (care.tempMax.value == null) 'tempMax',
      if (care.phMin.value == null) 'phMin',
      if (care.phMax.value == null) 'phMax',
    ];
  }

  static SpeciesCareCompanion _fillMissing(
      SpeciesCareCompanion care, SpeciesCareCompanion other) {
    Value<int?> pick(Value<int?> current, Value<int?> candidate) =>
        current.value != null || !candidate.present ? current : candidate;
    return care.copyWith(
      light: pick(care.light, other.light),
      humidity: pick(care.humidity, other.humidity),
      tempMin: pick(care.tempMin, other.tempMin),
      tempMax: pick(care.tempMax, other.tempMax),
      phMin: pick(care.phMin, other.phMin),
      phMax: pick(care.phMax, other.phMax),
    );
  }
}
