import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/data/service/search/species_searcher.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/species_searcher_result.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

/// Searches plant species by scientific or common name in the GBIF backbone
/// taxonomy (free, no API key). Species photos come from iNaturalist.
class GbifSearcher extends SpeciesSearcher {
  static const String baseUrl = "https://api.gbif.org/v1";
  static const String iNaturalistUrl = "https://api.inaturalist.org/v1";
  // GBIF Backbone Taxonomy dataset and the Plantae kingdom key
  static const String backboneDatasetKey =
      "d7dddbf4-2cf0-4f39-9b2a-bb099caae36c";
  static const int plantaeKey = 6;

  final UserSettingRepository _userSettingRepository;
  final Logger _log = Logger("GbifSearcher");

  GbifSearcher({
    required UserSettingRepository userSettingRepository,
  }) : _userSettingRepository = userSettingRepository;

  Future<bool> isEnabled() async {
    Result<String> enabled = await _userSettingRepository.getOrDefault(
        UserSettingsKeys.useGbif.key, "true");
    return enabled.getOrDefault("true") == "true";
  }

  @override
  Future<Result<List<SpeciesSearcherPartialResult>>> search(
      String term, int offset, int limit) async {
    if (term.trim().isEmpty || !await isEnabled()) {
      return Success([]);
    }

    Uri url = Uri.parse("$baseUrl/species/search").replace(queryParameters: {
      'q': term.trim(),
      'datasetKey': backboneDatasetKey,
      'highertaxonKey': plantaeKey.toString(),
      'rank': 'SPECIES',
      'status': 'ACCEPTED',
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    http.Response response;
    try {
      response = await http.get(url);
    } catch (e) {
      return Failure(Exception("Error while loading species from GBIF: $e"));
    }
    if (response.statusCode != 200) {
      return Failure(Exception("Error while loading species from GBIF"));
    }

    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> results = jsonResponse['results'] ?? [];
    List<_GbifSpeciesDTO> dtos = results
        .map((e) => _GbifSpeciesDTO.fromJson(e))
        .where((dto) => dto.canonicalName.isNotEmpty)
        .toList();

    List<String?> images =
        await Future.wait(dtos.map((dto) => getImageUrl(dto.canonicalName)));
    List<SpeciesSearcherPartialResult> species = [];
    for (int i = 0; i < dtos.length; i++) {
      species.add(SpeciesSearcherPartialResult(
        speciesCompanion: dtos[i].toCompanion(images[i]),
      ));
    }
    return Success(species);
  }

  @override
  Future<Result<SpeciesSearcherResult>> getDetails(String id) async {
    http.Response response;
    try {
      response = await http.get(Uri.parse("$baseUrl/species/$id"));
    } catch (e) {
      return Failure(Exception("Error while loading species from GBIF: $e"));
    }
    if (response.statusCode != 200) {
      return Failure(Exception("Error while loading species from GBIF"));
    }
    _GbifSpeciesDTO dto =
        _GbifSpeciesDTO.fromJson(json.decode(utf8.decode(response.bodyBytes)));

    List<String> commonNames = await getCommonNames(id);
    String? imageUrl = await getImageUrl(dto.canonicalName);

    return Success(SpeciesSearcherResult(
      speciesCompanion: dto.toCompanion(imageUrl),
      speciesCareCompanion: const SpeciesCareCompanion(species: Value(-1)),
      speciesSynonymsCompanion: commonNames
          .map((name) => SpeciesSynonymsCompanion(
                id: const Value(-1),
                species: const Value(-1),
                synonym: Value(_cut(name, 100)),
              ))
          .toList(),
    ));
  }

  /// Resolves a scientific name to a GBIF backbone species, used when the
  /// photo identification service does not return a GBIF id.
  Future<String?> matchKey(String scientificName) async {
    Uri url = Uri.parse("$baseUrl/species/match").replace(queryParameters: {
      'name': scientificName,
      'kingdom': 'Plantae',
    });
    try {
      http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        return null;
      }
      Map<String, dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['matchType'] == 'NONE') {
        return null;
      }
      return (jsonResponse['speciesKey'] ?? jsonResponse['usageKey'])
          ?.toString();
    } catch (e) {
      _log.warning("Error while matching $scientificName on GBIF: $e");
      return null;
    }
  }

  /// Common names in the device language first, then in English.
  Future<List<String>> getCommonNames(String id) async {
    try {
      http.Response response = await http
          .get(Uri.parse("$baseUrl/species/$id/vernacularNames?limit=200"));
      if (response.statusCode != 200) {
        return [];
      }
      Map<String, dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'] ?? [];
      Set<String> deviceLanguage = _languageCodes(_deviceLanguage());
      Set<String> english = _languageCodes("en");

      List<String> preferred = [];
      List<String> fallback = [];
      for (dynamic r in results) {
        String? name = r['vernacularName'];
        String language = (r['language'] ?? "").toString().toLowerCase();
        if (name == null || name.trim().isEmpty) {
          continue;
        }
        name = _capitalize(name.trim());
        if (deviceLanguage.contains(language)) {
          preferred.add(name);
        } else if (english.contains(language)) {
          fallback.add(name);
        }
      }
      List<String> names = [];
      for (String name in [...preferred, ...fallback]) {
        if (!names.any((n) => n.toLowerCase() == name.toLowerCase())) {
          names.add(name);
        }
      }
      return names.take(10).toList();
    } catch (e) {
      _log.warning("Error while loading common names from GBIF: $e");
      return [];
    }
  }

  /// A photo of the species from iNaturalist, if any.
  Future<String?> getImageUrl(String scientificName) async {
    Uri url = Uri.parse("$iNaturalistUrl/taxa").replace(queryParameters: {
      'q': scientificName,
      'rank': 'species',
      'per_page': '1',
    });
    try {
      http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        return null;
      }
      Map<String, dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> results = jsonResponse['results'] ?? [];
      if (results.isEmpty) {
        return null;
      }
      dynamic taxon = results.first;
      if ((taxon['name'] ?? "").toString().toLowerCase() !=
          scientificName.toLowerCase()) {
        return null;
      }
      return taxon['default_photo']?['medium_url'];
    } catch (e) {
      _log.warning("Error while loading image from iNaturalist: $e");
      return null;
    }
  }

  /// A short summary of the species from Wikipedia, through iNaturalist, in
  /// the device language when available.
  Future<String?> getSummary(String scientificName) async {
    String locale = _deviceLanguage();
    try {
      http.Response search = await http
          .get(Uri.parse("$iNaturalistUrl/taxa").replace(queryParameters: {
        'q': scientificName,
        'rank': 'species',
        'per_page': '1',
      }));
      if (search.statusCode != 200) {
        return null;
      }
      List<dynamic> results =
          json.decode(utf8.decode(search.bodyBytes))['results'] ?? [];
      if (results.isEmpty ||
          (results.first['name'] ?? "").toString().toLowerCase() !=
              scientificName.toLowerCase()) {
        return null;
      }
      http.Response taxon = await http.get(
          Uri.parse("$iNaturalistUrl/taxa/${results.first['id']}")
              .replace(queryParameters: {'locale': locale}));
      if (taxon.statusCode != 200) {
        return null;
      }
      List<dynamic> details =
          json.decode(utf8.decode(taxon.bodyBytes))['results'] ?? [];
      if (details.isEmpty) {
        return null;
      }
      return cleanSummary(details.first['wikipedia_summary']);
    } catch (e) {
      _log.warning("Error while loading summary from iNaturalist: $e");
      return null;
    }
  }

  /// Removes the HTML of a Wikipedia summary and keeps its first sentences.
  static String? cleanSummary(String? html) {
    if (html == null) {
      return null;
    }
    String text = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) {
      return null;
    }
    if (text.length <= 600) {
      return text;
    }
    int cut = text.lastIndexOf('. ', 600);
    return cut > 100
        ? text.substring(0, cut + 1)
        : "${text.substring(0, 600)}…";
  }

  static String _deviceLanguage() =>
      PlatformDispatcher.instance.locale.languageCode;

  // GBIF uses ISO 639-2 codes ("spa"), but some datasets use ISO 639-1 ("es")
  static Set<String> _languageCodes(String iso6391) {
    const Map<String, List<String>> codes = {
      'en': ['en', 'eng'],
      'es': ['es', 'spa'],
      'it': ['it', 'ita'],
      'fr': ['fr', 'fra', 'fre'],
      'de': ['de', 'deu', 'ger'],
      'pt': ['pt', 'por'],
    };
    return (codes[iso6391] ?? [iso6391]).toSet();
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

String _cut(String s, int max) => s.length <= max ? s : s.substring(0, max);

class _GbifSpeciesDTO {
  final String key;
  final String canonicalName;
  final String? authorship;
  final String? family;
  final String? genus;

  _GbifSpeciesDTO({
    required this.key,
    required this.canonicalName,
    this.authorship,
    this.family,
    this.genus,
  });

  factory _GbifSpeciesDTO.fromJson(Map<String, dynamic> json) {
    String? authorship = json['authorship']?.toString().trim();
    return _GbifSpeciesDTO(
      key: (json['speciesKey'] ?? json['key']).toString(),
      canonicalName:
          (json['canonicalName'] ?? json['species'] ?? "").toString().trim(),
      authorship: (authorship ?? "").isEmpty ? null : authorship,
      family: json['family'],
      genus: json['genus'],
    );
  }

  SpeciesCompanion toCompanion(String? imageUrl) {
    return SpeciesCompanion(
      id: const Value(-1),
      scientificName: Value(_cut(canonicalName, 50)),
      family: Value(family == null ? null : _cut(family!, 50)),
      genus: Value(genus == null ? null : _cut(genus!, 50)),
      species: Value(_cut(canonicalName, 50)),
      author: Value(authorship == null ? null : _cut(authorship!, 100)),
      externalAvatarUrl:
          imageUrl == null ? const Value.absent() : Value(imageUrl),
      dataSource: const Value(SpeciesDataSource.gbif),
      externalId: Value(key),
    );
  }
}
