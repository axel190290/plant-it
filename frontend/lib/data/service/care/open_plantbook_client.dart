import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

class PlantNotFoundException implements Exception {
  final String scientificName;

  PlantNotFoundException(this.scientificName);

  @override
  String toString() => "$scientificName not found in Open Plantbook";
}

/// Reads measured care ranges (light, temperature, humidity) from
/// Open Plantbook and converts them to the scales used by the app.
class OpenPlantbookClient {
  static const String baseUrl = "https://open.plantbook.io/api/v1";

  final UserSettingRepository _userSettingRepository;
  final Logger _log = Logger("OpenPlantbookClient");
  String? _token;
  String? _tokenClientId;
  DateTime? _tokenExpiry;

  OpenPlantbookClient({
    required UserSettingRepository userSettingRepository,
  }) : _userSettingRepository = userSettingRepository;

  Future<bool> isConfigured() async {
    (String, String) credentials = await _credentials();
    return credentials.$1.isNotEmpty && credentials.$2.isNotEmpty;
  }

  /// Care for the given scientific name. Fails with [PlantNotFoundException]
  /// if the plant is unknown to Open Plantbook.
  Future<Result<SpeciesCareCompanion>> getCare(String scientificName) async {
    Result<String> token = await _getToken();
    if (token.isError()) {
      return Failure(token.exceptionOrNull()!);
    }
    Map<String, String> headers = {
      'Authorization': 'Bearer ${token.getOrThrow()}',
    };

    try {
      String? pid = await _findPid(scientificName, headers);
      if (pid == null) {
        return Failure(PlantNotFoundException(scientificName));
      }
      http.Response response = await http.get(
          Uri.parse("$baseUrl/plant/detail/${Uri.encodeComponent(pid)}/"),
          headers: headers);
      if (response.statusCode == 404) {
        return Failure(PlantNotFoundException(scientificName));
      }
      if (response.statusCode != 200) {
        return Failure(Exception(
            "Error while loading care from Open Plantbook (${response.statusCode})"));
      }
      return Success(toCare(json.decode(utf8.decode(response.bodyBytes))));
    } catch (e) {
      return Failure(
          Exception("Error while loading care from Open Plantbook: $e"));
    }
  }

  Future<String?> _findPid(
      String scientificName, Map<String, String> headers) async {
    Uri url = Uri.parse("$baseUrl/plant/search")
        .replace(queryParameters: {'alias': scientificName, 'limit': '10'});
    http.Response response = await http.get(url, headers: headers);
    if (response.statusCode != 200) {
      _log.warning("Open Plantbook search failed (${response.statusCode})");
      return null;
    }
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> results = jsonResponse['results'] ?? [];
    String wanted = scientificName.toLowerCase().trim();
    for (dynamic r in results) {
      String pid = (r['pid'] ?? "").toString();
      String displayPid = (r['display_pid'] ?? "").toString().toLowerCase();
      if (pid.toLowerCase() == wanted || displayPid == wanted) {
        return pid;
      }
    }
    return null;
  }

  /// Converts an Open Plantbook plant detail into the app's care scales:
  /// light 1-10 (from lux, logarithmic), humidity 0-10 (from %),
  /// temperature in °C. Open Plantbook has no soil pH.
  static SpeciesCareCompanion toCare(Map<String, dynamic> detail) {
    num? minLux = detail['min_light_lux'];
    num? maxLux = detail['max_light_lux'];
    num? minHumid = detail['min_env_humid'];
    num? maxHumid = detail['max_env_humid'];
    num? minTemp = detail['min_temp'];
    num? maxTemp = detail['max_temp'];

    int? light;
    double? lux = _middle(minLux, maxLux, geometric: true);
    if (lux != null && lux > 0) {
      // 500 lux (deep shade) -> 1, 100000 lux (full sun) -> 10
      double position = (log(lux) - log(500)) / (log(100000) - log(500));
      light = (1 + 9 * position).round().clamp(1, 10);
    }

    int? humidity;
    double? humidityPercent = _middle(minHumid, maxHumid);
    if (humidityPercent != null) {
      humidity = (humidityPercent / 10).round().clamp(0, 10);
    }

    return SpeciesCareCompanion(
      species: const Value(-1),
      light: Value(light),
      humidity: Value(humidity),
      tempMin: Value(minTemp?.round().clamp(-30, 50)),
      tempMax: Value(maxTemp?.round().clamp(-30, 50)),
      phMin: const Value(null),
      phMax: const Value(null),
    );
  }

  static double? _middle(num? a, num? b, {bool geometric = false}) {
    if (a != null && b != null) {
      if (geometric && a > 0 && b > 0) {
        return sqrt(a * b);
      }
      return (a + b) / 2;
    }
    return (a ?? b)?.toDouble();
  }

  Future<(String, String)> _credentials() async {
    Result<String> id = await _userSettingRepository.getOrDefault(
        UserSettingsKeys.plantbookClientId.key, "");
    Result<String> secret = await _userSettingRepository.getOrDefault(
        UserSettingsKeys.plantbookClientSecret.key, "");
    return (id.getOrDefault("").trim(), secret.getOrDefault("").trim());
  }

  Future<Result<String>> _getToken() async {
    (String, String) credentials = await _credentials();
    if (credentials.$1.isEmpty || credentials.$2.isEmpty) {
      return Failure(Exception("Missing Open Plantbook credentials"));
    }
    if (_token != null &&
        _tokenClientId == credentials.$1 &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return Success(_token!);
    }

    http.Response response;
    try {
      response = await http.post(Uri.parse("$baseUrl/token/"), body: {
        'grant_type': 'client_credentials',
        'client_id': credentials.$1,
        'client_secret': credentials.$2,
      });
    } catch (e) {
      return Failure(Exception("Error while contacting Open Plantbook: $e"));
    }
    if (response.statusCode != 200) {
      return Failure(Exception("Open Plantbook rejected the credentials"));
    }
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    _token = jsonResponse['access_token'];
    _tokenClientId = credentials.$1;
    int expiresIn = (jsonResponse['expires_in'] as num?)?.toInt() ?? 3600;
    _tokenExpiry =
        DateTime.now().add(Duration(seconds: max(60, expiresIn - 60)));
    if (_token == null) {
      return Failure(Exception("Open Plantbook did not return a token"));
    }
    return Success(_token!);
  }
}
