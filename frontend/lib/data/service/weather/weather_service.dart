import 'dart:convert';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:result_dart/result_dart.dart';

class LocationPermissionException implements Exception {
  @override
  String toString() => "Location permission denied";
}

/// Local weather from Open-Meteo (free, no API key) for the place chosen in
/// the settings, by name or from the device location.
class WeatherService {
  static const String forecastUrl = "https://api.open-meteo.com/v1/forecast";
  static const String geocodingUrl =
      "https://geocoding-api.open-meteo.com/v1/search";
  static const Duration cacheDuration = Duration(hours: 1);

  final UserSettingRepository _userSettingRepository;
  Weather? _cached;
  DateTime? _cachedAt;

  WeatherService({required UserSettingRepository userSettingRepository})
      : _userSettingRepository = userSettingRepository;

  Future<Place?> currentPlace() async {
    String name = (await _userSettingRepository.getOrDefault(
            UserSettingsKeys.weatherPlace.key, ""))
        .getOrDefault("");
    double? latitude = double.tryParse((await _userSettingRepository
            .getOrDefault(UserSettingsKeys.weatherLatitude.key, ""))
        .getOrDefault(""));
    double? longitude = double.tryParse((await _userSettingRepository
            .getOrDefault(UserSettingsKeys.weatherLongitude.key, ""))
        .getOrDefault(""));
    if (latitude == null || longitude == null) {
      return null;
    }
    return Place(name, latitude, longitude);
  }

  Future<Result<void>> setPlace(Place? place) async {
    _cached = null;
    for ((UserSettingsKeys, String?) setting in [
      (UserSettingsKeys.weatherPlace, place?.name),
      (UserSettingsKeys.weatherLatitude, place?.latitude.toString()),
      (UserSettingsKeys.weatherLongitude, place?.longitude.toString()),
    ]) {
      Result<void> result = setting.$2 == null
          ? await _userSettingRepository.remove(setting.$1.key)
          : await _userSettingRepository.put(setting.$1.key, setting.$2!);
      if (result.isError()) {
        return result;
      }
    }
    return Success("ok");
  }

  /// Places whose name matches [name], in the device language.
  Future<Result<List<Place>>> searchPlaces(String name) async {
    Uri url = Uri.parse(geocodingUrl).replace(queryParameters: {
      'name': name.trim(),
      'count': '8',
      'language': PlatformDispatcher.instance.locale.languageCode,
    });
    try {
      http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        return Failure(Exception("Error while searching the place"));
      }
      List<dynamic> results =
          json.decode(utf8.decode(response.bodyBytes))['results'] ?? [];
      return Success(results.map((r) {
        String label = [r['name'], r['admin1'], r['country']]
            .where((p) => p != null && p.toString().isNotEmpty)
            .toSet()
            .join(', ');
        return Place(label, (r['latitude'] as num).toDouble(),
            (r['longitude'] as num).toDouble());
      }).toList());
    } catch (e) {
      return Failure(Exception("Error while searching the place: $e"));
    }
  }

  /// The approximate device location, asking the permission if needed.
  Future<Result<Place>> devicePlace(String name) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return Failure(LocationPermissionException());
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return Failure(LocationPermissionException());
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      // Rounded: the weather does not need more and it keeps it private
      double round(double v) => (v * 100).roundToDouble() / 100;
      return Success(
          Place(name, round(position.latitude), round(position.longitude)));
    } catch (e) {
      return Failure(Exception("Error while reading the location: $e"));
    }
  }

  /// The weather of the chosen place, or a failure if there is none.
  Future<Result<Weather>> getWeather({bool refresh = false}) async {
    if (!refresh &&
        _cached != null &&
        DateTime.now().difference(_cachedAt!) < cacheDuration) {
      return Success(_cached!);
    }
    Place? place = await currentPlace();
    if (place == null) {
      return Failure(Exception("No place configured"));
    }
    Uri url = Uri.parse(forecastUrl).replace(queryParameters: {
      'latitude': place.latitude.toString(),
      'longitude': place.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,weather_code',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,'
          'precipitation_probability_max,weather_code',
      'forecast_days': '3',
      'timezone': 'auto',
    });
    try {
      http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        return Failure(Exception("Error while loading the weather"));
      }
      _cached =
          parseForecast(place, json.decode(utf8.decode(response.bodyBytes)));
      _cachedAt = DateTime.now();
      return Success(_cached!);
    } catch (e) {
      return Failure(Exception("Error while loading the weather: $e"));
    }
  }

  static Weather parseForecast(Place place, Map<String, dynamic> json) {
    Map<String, dynamic> current = json['current'] ?? {};
    Map<String, dynamic> daily = json['daily'] ?? {};
    List<dynamic> dates = daily['time'] ?? [];
    T? at<T>(String key, int i) {
      List<dynamic>? values = daily[key];
      if (values == null || i >= values.length) return null;
      return values[i] as T?;
    }

    return Weather(
      place: place.name,
      latitude: place.latitude,
      temperature: (current['temperature_2m'] as num?)?.toDouble(),
      humidity: (current['relative_humidity_2m'] as num?)?.round(),
      weatherCode: (current['weather_code'] as num?)?.round(),
      days: [
        for (int i = 0; i < dates.length; i++)
          DayForecast(
            date: DateTime.parse(dates[i]),
            min: at<num>('temperature_2m_min', i)?.toDouble(),
            max: at<num>('temperature_2m_max', i)?.toDouble(),
            precipitation: at<num>('precipitation_sum', i)?.toDouble(),
            precipitationProbability:
                at<num>('precipitation_probability_max', i)?.round(),
            weatherCode: at<num>('weather_code', i)?.round(),
          ),
      ],
    );
  }
}
