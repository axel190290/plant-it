import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/search/gbif_searcher.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/species_searcher_result.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

class MissingApiKeyException implements Exception {
  final String service;

  MissingApiKeyException(this.service);

  @override
  String toString() => "Missing $service API key";
}

/// Identifies plant species from photos using the Pl@ntNet API.
/// Results are linked to GBIF species, so a plant found by photo opens
/// the same species page as the one found by name.
class PlantNetIdentifier {
  static const String baseUrl = "https://my-api.plantnet.org/v2";
  static const List<String> supportedLanguages = ["en", "es", "fr", "it"];

  final UserSettingRepository _userSettingRepository;
  final GbifSearcher _gbifSearcher;

  PlantNetIdentifier({
    required UserSettingRepository userSettingRepository,
    required GbifSearcher gbifSearcher,
  })  : _userSettingRepository = userSettingRepository,
        _gbifSearcher = gbifSearcher;

  Future<Result<List<SpeciesSearcherPartialResult>>> identify(
      List<File> images) async {
    Result<String> keyResult = await _userSettingRepository.getOrDefault(
        UserSettingsKeys.plantNetKey.key, "");
    String apiKey = keyResult.getOrDefault("").trim();
    if (apiKey.isEmpty) {
      return Failure(MissingApiKeyException("Pl@ntNet"));
    }

    String language = PlatformDispatcher.instance.locale.languageCode;
    if (!supportedLanguages.contains(language)) {
      language = "en";
    }
    Uri url = Uri.parse("$baseUrl/identify/all").replace(queryParameters: {
      'api-key': apiKey,
      'lang': language,
      'nb-results': '5',
      'include-related-images': 'false',
    });

    http.MultipartRequest request = http.MultipartRequest('POST', url);
    // "organs" is omitted, so Pl@ntNet detects the organ of each image itself
    for (File image in images.take(5)) {
      request.files
          .add(await http.MultipartFile.fromPath('images', image.path));
    }

    http.Response response;
    try {
      response = await http.Response.fromStream(await request.send());
    } catch (e) {
      return Failure(Exception("Error while contacting Pl@ntNet: $e"));
    }
    if (response.statusCode == 404) {
      // Pl@ntNet answers 404 when no species matches the photo
      return Success([]);
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      return Failure(Exception("Pl@ntNet rejected the API key"));
    }
    if (response.statusCode != 200) {
      return Failure(Exception(
          "Error while identifying the plant with Pl@ntNet (${response.statusCode})"));
    }

    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> results = jsonResponse['results'] ?? [];

    List<Future<SpeciesSearcherPartialResult?>> species =
        results.map((r) => _toPartialResult(r)).toList();
    return Success((await Future.wait(species))
        .whereType<SpeciesSearcherPartialResult>()
        .toList());
  }

  Future<SpeciesSearcherPartialResult?> _toPartialResult(dynamic r) async {
    dynamic s = r['species'];
    if (s == null) {
      return null;
    }
    String? name = s['scientificNameWithoutAuthor'];
    if (name == null || name.isEmpty) {
      return null;
    }
    String? gbifKey = r['gbif']?['id']?.toString();
    gbifKey ??= await _gbifSearcher.matchKey(name);
    if (gbifKey == null) {
      return null;
    }
    String? author = s['scientificNameAuthorship'];
    String? genus = s['genus']?['scientificNameWithoutAuthor'];
    String? family = s['family']?['scientificNameWithoutAuthor'];
    String? imageUrl = await _gbifSearcher.getImageUrl(name);

    return SpeciesSearcherPartialResult(
      confidence: (r['score'] as num?)?.toDouble(),
      speciesCompanion: SpeciesCompanion(
        id: const Value(-1),
        scientificName: Value(_cut(name, 50)),
        family: Value(family == null ? null : _cut(family, 50)),
        genus: Value(genus == null ? null : _cut(genus, 50)),
        species: Value(_cut(name, 50)),
        author:
            Value(author == null || author.isEmpty ? null : _cut(author, 100)),
        externalAvatarUrl:
            imageUrl == null ? const Value.absent() : Value(imageUrl),
        dataSource: const Value(SpeciesDataSource.gbif),
        externalId: Value(gbifKey),
      ),
    );
  }

  static String _cut(String s, int max) =>
      s.length <= max ? s : s.substring(0, max);
}
