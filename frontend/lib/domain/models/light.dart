/// Light for plants: from the lux a phone measures to the daily light
/// integral (DLI), the photosynthetic light a plant gets in a day, in
/// mol/m²/day.
library;

/// Photosynthetic photon flux (µmol/m²/s) of sunlight per lux.
const double ppfdPerLux = 0.0185;

/// Readings further apart than this are not joined: the phone was off.
const Duration _maxGap = Duration(minutes: 30);

class LightSample {
  final DateTime time;
  final double lux;

  const LightSample(this.time, this.lux);
}

/// The light integral of [samples] in mol/m², joining consecutive samples
/// by their average.
double lightIntegral(List<LightSample> samples) {
  List<LightSample> sorted = [...samples]
    ..sort((a, b) => a.time.compareTo(b.time));
  double total = 0;
  for (int i = 1; i < sorted.length; i++) {
    Duration gap = sorted[i].time.difference(sorted[i - 1].time);
    if (gap <= Duration.zero || gap > _maxGap) continue;
    double lux = (sorted[i].lux + sorted[i - 1].lux) / 2;
    total += lux * ppfdPerLux * gap.inMilliseconds / 1000 / 1e6;
  }
  return total;
}

/// The light integral of each day with [samples], by the date of the day.
Map<DateTime, double> dailyLightIntegrals(List<LightSample> samples) {
  Map<DateTime, List<LightSample>> byDay = {};
  for (LightSample s in samples) {
    DateTime t = s.time.toLocal();
    byDay.putIfAbsent(DateTime(t.year, t.month, t.day), () => []).add(s);
  }
  return byDay.map((day, list) => MapEntry(day, lightIntegral(list)));
}

/// The daily light integral, as a range, a species wants: from the lux of
/// its care, assuming twelve hours of light, else from its light level
/// (1 deep shade to 10 full sun).
(double, double)? dliRange({int? light, double? luxMin, double? luxMax}) {
  double perLux = ppfdPerLux * 12 * 3600 / 1e6;
  if (luxMin != null && luxMin > 0) {
    double max = luxMax != null && luxMax > luxMin ? luxMax : luxMin * 3;
    return (luxMin * perLux, max * perLux);
  }
  if (light == null) return null;
  return switch (light.clamp(1, 10)) {
    1 || 2 => (2.0, 4.0),
    3 || 4 => (4.0, 8.0),
    5 || 6 => (8.0, 14.0),
    7 || 8 => (14.0, 22.0),
    _ => (22.0, 40.0),
  };
}

enum CompassPoint { n, ne, e, se, s, sw, w, nw }

/// The compass point of [azimuth] degrees from the north.
CompassPoint compassPoint(double azimuth) =>
    CompassPoint.values[(((azimuth % 360) + 22.5) ~/ 45) % 8];
