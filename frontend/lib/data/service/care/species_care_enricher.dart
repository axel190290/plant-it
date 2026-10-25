import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/open_plantbook_client.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';
import 'package:result_dart/result_dart.dart';

/// Completes the care of an external species: first with the measured
/// values of Open Plantbook, then, only for the values still missing,
/// with an AI estimate. Every source used is recorded in [CareSources].
class SpeciesCareEnricher {
  final OpenPlantbookClient _openPlantbookClient;
  final AiCareEstimator _aiCareEstimator;
  final Logger _log = Logger("SpeciesCareEnricher");

  SpeciesCareEnricher({
    required OpenPlantbookClient openPlantbookClient,
    required AiCareEstimator aiCareEstimator,
  })  : _openPlantbookClient = openPlantbookClient,
        _aiCareEstimator = aiCareEstimator;

  /// Never fails: a source that is not configured or not reachable is
  /// skipped and the values it would give stay empty.
  Future<(SpeciesCareCompanion, CareSources)> enrich({
    required String scientificName,
    String? family,
    required SpeciesCareCompanion care,
    required CareSources sources,
  }) async {
    if (_missingFields(care).isNotEmpty &&
        await _openPlantbookClient.isConfigured()) {
      Result<SpeciesCareCompanion> plantbook =
          await _openPlantbookClient.getCare(scientificName);
      if (plantbook.isError()) {
        _log.info(plantbook.exceptionOrNull());
      } else {
        SpeciesCareCompanion before = care;
        care = _fillMissing(care, plantbook.getOrThrow());
        if (_missingFields(before).length != _missingFields(care).length) {
          sources = sources.copyWith(care: CareSources.openPlantbook);
        }
      }
    }

    List<String> missing = _missingFields(care);
    if (missing.isEmpty) {
      return (care, sources);
    }
    AiProvider provider = await _aiCareEstimator.configuredProvider();
    if (provider == AiProvider.none) {
      return (care, sources);
    }
    Result<SpeciesCareCompanion> estimate =
        await _aiCareEstimator.estimate(provider, scientificName, family);
    if (estimate.isError()) {
      _log.warning(estimate.exceptionOrNull());
      return (care, sources);
    }
    care = _fillMissing(care, estimate.getOrThrow());
    List<String> estimated =
        missing.where((f) => !_missingFields(care).contains(f)).toList();
    if (estimated.isNotEmpty) {
      sources = sources.copyWith(
        aiProvider: provider.key,
        aiFields: CareSources.groupFields(estimated),
      );
    }
    return (care, sources);
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
