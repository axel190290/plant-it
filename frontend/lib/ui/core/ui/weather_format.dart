import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

// WMO weather codes, as used by Open-Meteo
enum _Sky { clear, partlyCloudy, cloudy, fog, drizzle, rain, snow, storm }

_Sky _sky(int? code) => switch (code) {
      null || 0 => _Sky.clear,
      1 || 2 => _Sky.partlyCloudy,
      3 => _Sky.cloudy,
      45 || 48 => _Sky.fog,
      >= 51 && <= 57 => _Sky.drizzle,
      >= 71 && <= 77 || 85 || 86 => _Sky.snow,
      >= 95 => _Sky.storm,
      _ => _Sky.rain,
    };

IconData weatherIcon(int? code) => switch (_sky(code)) {
      _Sky.clear => LucideIcons.sun,
      _Sky.partlyCloudy => LucideIcons.cloud_sun,
      _Sky.cloudy => LucideIcons.cloud,
      _Sky.fog => LucideIcons.cloud_fog,
      _Sky.drizzle => LucideIcons.cloud_drizzle,
      _Sky.rain => LucideIcons.cloud_rain,
      _Sky.snow => LucideIcons.cloud_snow,
      _Sky.storm => LucideIcons.cloud_lightning,
    };

String weatherLabel(L l, int? code) => switch (_sky(code)) {
      _Sky.clear => l.weatherClear,
      _Sky.partlyCloudy => l.weatherPartlyCloudy,
      _Sky.cloudy => l.weatherCloudy,
      _Sky.fog => l.weatherFog,
      _Sky.drizzle => l.weatherDrizzle,
      _Sky.rain => l.weatherRain,
      _Sky.snow => l.weatherSnow,
      _Sky.storm => l.weatherStorm,
    };

String seasonLabel(L l, Season season) => switch (season) {
      Season.spring => l.seasonSpring,
      Season.summer => l.seasonSummer,
      Season.autumn => l.seasonAutumn,
      Season.winter => l.seasonWinter,
      Season.dry => l.seasonDry,
      Season.rainy => l.seasonRainy,
    };

/// "Today", "Tomorrow" or the weekday of [date].
String dayLabel(L l, DateTime date) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  int days = DateTime(date.year, date.month, date.day).difference(today).inDays;
  if (days == 0) return l.today;
  if (days == 1) return l.tomorrow;
  return toBeginningOfSentenceCase(DateFormat.EEEE(l.localeName).format(date));
}

String temperatureText(double? t) => t == null ? '—' : '${t.round()} °C';

/// The care category keys of the watering of [season], if it has one.
Set<String> currentSeasonCareKeys(Season? season) => switch (season) {
      Season.summer => {'watering_summer'},
      Season.winter => {'watering_winter'},
      _ => {},
    };
