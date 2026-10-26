import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/domain/models/weather.dart';

void main() {
  group('Weather.seasonFor', () {
    test('follows the hemisphere', () {
      DateTime january = DateTime(2026, 1, 15);
      DateTime july = DateTime(2026, 7, 15);
      DateTime october = DateTime(2026, 10, 26);
      expect(Weather.seasonFor(january, 40.4), Season.winter);
      expect(Weather.seasonFor(july, 40.4), Season.summer);
      expect(Weather.seasonFor(october, 40.4), Season.autumn);
      expect(Weather.seasonFor(january, -34.6), Season.summer);
      expect(Weather.seasonFor(october, -34.6), Season.spring);
    });

    test('is dry or rainy between the tropics', () {
      DayForecast wet =
          DayForecast(date: DateTime(2026, 7, 1), precipitation: 8);
      DayForecast dry =
          DayForecast(date: DateTime(2026, 7, 1), precipitation: 0);
      expect(Weather.seasonFor(DateTime(2026, 7, 1), 19.4, days: [wet]),
          Season.rainy);
      expect(Weather.seasonFor(DateTime(2026, 7, 1), 19.4, days: [dry]),
          Season.dry);
    });
  });

  test('WeatherService.parseForecast reads Open-Meteo', () {
    Weather weather = WeatherService.parseForecast(
      const Place('Madrid', 40.42, -3.70),
      {
        'current': {
          'temperature_2m': 18.4,
          'relative_humidity_2m': 65,
          'weather_code': 2,
        },
        'daily': {
          'time': ['2026-10-26', '2026-10-27'],
          'temperature_2m_min': [9.1, 2.6],
          'temperature_2m_max': [21.0, 15.2],
          'precipitation_sum': [0.0, 4.5],
          'precipitation_probability_max': [10, 80],
          'weather_code': [2, 61],
        },
      },
    );
    expect(weather.temperature, 18.4);
    expect(weather.humidity, 65);
    expect(weather.days.length, 2);
    expect(weather.days[1].min, 2.6);
    expect(weather.days[1].rainy, isTrue);
    expect(weather.today!.rainy, isFalse);
  });

  test('weatherAlerts warns about frost, heat and rain', () {
    Weather weather = Weather(
      place: 'Madrid',
      latitude: 40.42,
      days: [
        DayForecast(
            date: DateTime(2026, 10, 26), min: 9, max: 36, precipitation: 5),
        DayForecast(date: DateTime(2026, 10, 27), min: 2, max: 15),
      ],
    );
    List<WeatherAlert> alerts = weatherAlerts(weather, const [
      OutdoorPlant('Monstera', 12, 30),
      OutdoorPlant('Lavanda', -10, 40),
      OutdoorPlant('Cactus', null, null),
    ]);
    expect(alerts.length, 2);
    // The first day beyond its range: on the 26th it drops below 12 °C
    expect(alerts[0].type, WeatherAlertType.frost);
    expect(alerts[0].plants, ['Monstera']);
    expect(alerts[0].temperature, 9);
    expect(alerts[1].type, WeatherAlertType.rain);
    expect(alerts[1].plants, ['Monstera', 'Lavanda', 'Cactus']);
    expect(weatherAlerts(weather, const []), isEmpty);
  });

  test('weatherAlerts asks to protect from heavy rain the plants that fear it',
      () {
    Weather weather = Weather(
      place: 'Madrid',
      latitude: 40.42,
      days: [
        DayForecast(date: DateTime(2026, 10, 26), precipitation: 3),
        DayForecast(date: DateTime(2026, 10, 27), precipitation: 12),
      ],
    );
    List<WeatherAlert> alerts = weatherAlerts(weather, const [
      OutdoorPlant('Echeveria', null, null, 15),
      OutdoorPlant('Helecho', null, null, 3),
    ]);
    expect(alerts.length, 2);
    expect(alerts[0].type, WeatherAlertType.protectFromRain);
    expect(alerts[0].plants, ['Echeveria']);
    expect(alerts[0].temperature, 15);
    expect(alerts[0].day!.date, DateTime(2026, 10, 27));
    expect(alerts[0].limit, 15);
    // Today it rains, but the protected plant is not told to skip watering
    expect(alerts[1].type, WeatherAlertType.rain);
    expect(alerts[1].plants, ['Helecho']);
  });
}
