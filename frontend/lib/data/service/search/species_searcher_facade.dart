import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/service/care/species_care_enricher.dart';
import 'package:plant_it/data/service/care/species_description_service.dart';
import 'package:plant_it/data/service/identify/plantnet_identifier.dart';
import 'package:plant_it/data/service/search/cache/app_cache.dart';
import 'package:plant_it/data/service/search/flora_codex_searcher.dart';
import 'package:plant_it/data/service/search/gbif_searcher.dart';
import 'package:plant_it/data/service/search/local_searcher.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/species_searcher_result.dart';
import 'package:result_dart/result_dart.dart';

class SpeciesSearcherFacade {
  final LocalSearcher _localSearcher;
  final FloraCodexSearcher _floraCodexSearcher;
  final GbifSearcher _gbifSearcher;
  final PlantNetIdentifier _plantNetIdentifier;
  final SpeciesCareEnricher _careEnricher;
  final SpeciesDescriptionService _descriptionService;
  final Logger _log = Logger("SpeciesSearcherFacade");
  final AppCache _cache;

  SpeciesSearcherFacade({
    required LocalSearcher localSearcher,
    required FloraCodexSearcher floraCodexSearcher,
    required GbifSearcher gbifSearcher,
    required PlantNetIdentifier plantNetIdentifier,
    required SpeciesCareEnricher careEnricher,
    required SpeciesDescriptionService descriptionService,
    required AppCache cache,
  })  : _localSearcher = localSearcher,
        _floraCodexSearcher = floraCodexSearcher,
        _gbifSearcher = gbifSearcher,
        _plantNetIdentifier = plantNetIdentifier,
        _careEnricher = careEnricher,
        _descriptionService = descriptionService,
        _cache = cache;

  Future<Result<List<SpeciesSearcherPartialResult>>> search(
      String term, int offset, int limit) async {
    String emptyToAsterisk = term.isEmpty ? AppCache.emptyChar : term;
    List<SpeciesSearcherPartialResult>? cacheResult =
        await _cacheHitSearch(emptyToAsterisk);
    if (cacheResult != null) {
      _log.fine("Cache hit");
      return Success(cacheResult);
    }
    _log.fine("Cache miss");

    List<SpeciesSearcherPartialResult> result = [];

    Result<List<SpeciesSearcherPartialResult>> localResult =
        await _localSearcher.search(term, offset, limit);
    if (localResult.isError()) {
      return Failure(Exception(localResult.exceptionOrNull()));
    }
    result.addAll(localResult.getOrThrow());

    Result<List<SpeciesSearcherPartialResult>> floraCodexResult =
        await _floraCodexSearcher.search(term, offset, limit);
    // An unreachable external source must not hide the results of the others
    if (floraCodexResult.isError()) {
      _log.warning(floraCodexResult.exceptionOrNull());
    } else {
      result.addAll(floraCodexResult.getOrThrow());
    }

    Result<List<SpeciesSearcherPartialResult>> gbifResult =
        await _gbifSearcher.search(term, offset, limit);
    if (gbifResult.isError()) {
      _log.warning(gbifResult.exceptionOrNull());
    } else {
      Set<String> names = result
          .map((r) => r.speciesCompanion.scientificName.value.toLowerCase())
          .toSet();
      result.addAll(gbifResult.getOrThrow().where((r) => !names
          .contains(r.speciesCompanion.scientificName.value.toLowerCase())));
    }

    await _saveCacheSearch(
        emptyToAsterisk, result.sublist(0, min(result.length, limit)));
    return Success(result.sublist(0, min(result.length, limit)));
  }

  Future<Result<SpeciesSearcherResult>> getDetails(
      SpeciesSearcherPartialResult species) async {
    if (species.speciesCompanion.dataSource.value == SpeciesDataSource.custom) {
      String id = species.speciesCompanion.externalId.value ??
          species.speciesCompanion.id.value.toString();
      SpeciesSearcherResult? cached =
          await _cacheHitDetails(id, SpeciesDataSource.custom);
      if (cached != null) {
        return Success(cached);
      }
      Result<SpeciesSearcherResult> result = await _localSearcher
          .getDetails(species.speciesCompanion.id.value.toString());
      if (result.isError()) {
        return result;
      }
      _saveCacheDetails(id, SpeciesDataSource.custom, result.getOrThrow());
      return result;
    }

    SpeciesDataSource source = species.speciesCompanion.dataSource.value;
    String cacheKey =
        "${species.speciesCompanion.externalId.value}_${source.name}_details";
    SpeciesSearcherResult? cached = await _cacheHitDetails(cacheKey, source);
    if (cached != null) {
      return Success(cached);
    }

    Result<SpeciesSearcherResult> result;
    if (source == SpeciesDataSource.floraCodex) {
      result = await _floraCodexSearcher
          .getDetails(species.speciesCompanion.externalId.value.toString());
    } else if (source == SpeciesDataSource.gbif) {
      result = await _gbifSearcher
          .getDetails(species.speciesCompanion.externalId.value.toString());
    } else {
      return Failure(Exception("missing or wrong data source value"));
    }
    if (result.isError()) {
      return result;
    }

    SpeciesSearcherResult details = await _withCare(result.getOrThrow());
    _saveCacheDetails(cacheKey, source, details);
    return Success(details);
  }

  /// Identifies the species in the given photos. Results open the same
  /// species details as a search by name.
  Future<Result<List<SpeciesSearcherPartialResult>>> identify(
      List<File> images) {
    return _plantNetIdentifier.identify(images);
  }

  Future<SpeciesSearcherResult> _withCare(SpeciesSearcherResult details) async {
    SpeciesCompanion species = details.speciesCompanion;
    (SpeciesCareCompanion, Map<String, CareValue>, CareSources) enriched =
        await _careEnricher.enrich(
      scientificName: species.scientificName.value,
      family: species.family.value,
      care: details.speciesCareCompanion,
      extra: details.careValues,
      sources: CareSources(species: species.dataSource.value.name),
    );
    String? description = await _descriptionService.describe(
      species.scientificName.value,
      species.family.value,
      aiValues: enriched.$2,
    );
    return SpeciesSearcherResult(
      speciesCompanion: species.copyWith(
        bibliography: Value(enriched.$3.encode()),
        description: Value(description),
      ),
      speciesCareCompanion: enriched.$1,
      speciesSynonymsCompanion: details.speciesSynonymsCompanion,
      careValues: enriched.$2,
    );
  }

  Future<List<SpeciesSearcherPartialResult>?> _cacheHitSearch(
      String term) async {
    String? result = _cache.getSpeciesSearch(term);
    if (result == null) {
      return null;
    }
    //_log.fine("cache reading:\n$result");
    List<dynamic> jsonList = jsonDecode(result);
    return jsonList
        .map((json) => SpeciesSearcherPartialResult.fromJson(json))
        .toList()
        .cast<SpeciesSearcherPartialResult>();
  }

  Future<void> _saveCacheSearch(
      String term, List<SpeciesSearcherPartialResult> result) {
    String value = jsonEncode(result
        .map((r) => SpeciesSearcherPartialResult(
              speciesCompanion: r.speciesCompanion,
            ).toJson())
        .toList());
    //_log.fine("cache saving:\n$value");
    return _cache.saveSpeciesSearch(term, value);
  }

  Future<SpeciesSearcherResult?> _cacheHitDetails(
      String id, SpeciesDataSource source) async {
    String? result = _cache.getSpeciesDetails(id, source);
    if (result == null) {
      return null;
    }
    //_log.fine("cache reading:\n$result");
    dynamic json = jsonDecode(result);
    return SpeciesSearcherResult.fromJson(json);
  }

  Future<void> _saveCacheDetails(
      String id, SpeciesDataSource source, SpeciesSearcherResult details) {
    String value = jsonEncode(details);
    //_log.fine("cache saving:\n$value");
    return _cache.saveSpeciesDetails(id, source, value);
  }
}
