enum Season { spring, summer, autumn, winter, dry, rainy }

class DayForecast {
  final DateTime date;
  final double? min;
  final double? max;
  final double? precipitation;
  final int? precipitationProbability;
  final int? weatherCode;

  const DayForecast({
    required this.date,
    this.min,
    this.max,
    this.precipitation,
    this.precipitationProbability,
    this.weatherCode,
  });

  /// Rain is expected: enough precipitation or a high probability of it.
  bool get rainy =>
      (precipitation ?? 0) >= 2 || (precipitationProbability ?? 0) >= 70;
}

class Weather {
  final String place;
  final double latitude;
  final double? temperature;
  final int? humidity;
  final int? weatherCode;
  final List<DayForecast> days;

  const Weather({
    required this.place,
    required this.latitude,
    this.temperature,
    this.humidity,
    this.weatherCode,
    this.days = const [],
  });

  DayForecast? get today => days.isEmpty ? null : days.first;

  /// The season at [latitude] on [date]. Between the tropics, where the
  /// four seasons do not apply, it is dry or rainy according to the
  /// forecast rain.
  static Season seasonFor(DateTime date, double latitude,
      {List<DayForecast> days = const []}) {
    if (latitude.abs() < 23.5) {
      double rain = days.fold(0, (sum, d) => sum + (d.precipitation ?? 0));
      return rain >= 5 ? Season.rainy : Season.dry;
    }
    // Meteorological seasons: December to February is northern winter
    int month = date.month;
    Season north = switch (month) {
      12 || 1 || 2 => Season.winter,
      3 || 4 || 5 => Season.spring,
      6 || 7 || 8 => Season.summer,
      _ => Season.autumn,
    };
    if (latitude >= 0) {
      return north;
    }
    return switch (north) {
      Season.winter => Season.summer,
      Season.summer => Season.winter,
      Season.spring => Season.autumn,
      _ => Season.spring,
    };
  }

  Season get season => seasonFor(DateTime.now(), latitude, days: days);
}

/// A place found by name.
class Place {
  final String name;
  final double latitude;
  final double longitude;

  const Place(this.name, this.latitude, this.longitude);
}

enum WeatherAlertType { frost, heat, rain, protectFromRain }

class WeatherAlert {
  final WeatherAlertType type;
  final List<String> plants;
  // Frost and heat: the day, its temperature and the plant limit.
  // Protection from rain: the first rainy day and the days between
  // waterings.
  final DayForecast? day;
  final double? temperature;
  final int? limit;
  // Protection from rain: rainy days among the forecast days
  final int? rainyDays;
  final int? forecastDays;

  const WeatherAlert({
    required this.type,
    required this.plants,
    this.day,
    this.temperature,
    this.limit,
    this.rainyDays,
    this.forecastDays,
  });
}

/// An outdoor plant and the temperatures its species withstands.
class OutdoorPlant {
  final String name;
  final int? tempMin;
  final int? tempMax;
  // Days between waterings in the current season, if known
  final int? wateringDays;

  const OutdoorPlant(this.name, this.tempMin, this.tempMax,
      [this.wateringDays]);
}

/// Frost and heat alerts for the outdoor plants whose species does not
/// withstand the forecast temperatures, and a rain alert when it rains
/// today.
List<WeatherAlert> weatherAlerts(Weather weather, List<OutdoorPlant> plants) {
  List<WeatherAlert> alerts = [];
  for (OutdoorPlant plant in plants) {
    for (DayForecast day in weather.days) {
      if (plant.tempMin != null &&
          day.min != null &&
          day.min! < plant.tempMin!) {
        alerts.add(WeatherAlert(
          type: WeatherAlertType.frost,
          plants: [plant.name],
          day: day,
          temperature: day.min,
          limit: plant.tempMin,
        ));
        break;
      }
      if (plant.tempMax != null &&
          day.max != null &&
          day.max! > plant.tempMax!) {
        alerts.add(WeatherAlert(
          type: WeatherAlertType.heat,
          plants: [plant.name],
          day: day,
          temperature: day.max,
          limit: plant.tempMax,
        ));
        break;
      }
    }
  }
  // Rain more often than a plant is watered: protect it from the rain
  List<DayForecast> rainyDays = weather.days.where((d) => d.rainy).toList();
  List<OutdoorPlant> protect = rainyDays.isEmpty
      ? []
      : plants
          .where((p) =>
              p.wateringDays != null &&
              weather.days.length / rainyDays.length < p.wateringDays!)
          .toList();
  for (OutdoorPlant plant in protect) {
    alerts.add(WeatherAlert(
      type: WeatherAlertType.protectFromRain,
      plants: [plant.name],
      day: rainyDays.first,
      limit: plant.wateringDays,
      rainyDays: rainyDays.length,
      forecastDays: weather.days.length,
    ));
  }
  List<OutdoorPlant> others =
      plants.where((p) => !protect.contains(p)).toList();
  if (others.isNotEmpty && (weather.today?.rainy ?? false)) {
    alerts.add(WeatherAlert(
      type: WeatherAlertType.rain,
      plants: others.map((p) => p.name).toList(),
    ));
  }
  return alerts;
}
