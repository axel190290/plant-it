import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/domain/models/weather.dart';

enum SuggestionKind {
  watering,
  fertilizing,
  pruning,
  repotting,
  pestCheck,
  misting,
  protectFromCold,
  moveOutdoors,
}

/// Names of the event types each suggestion creates reminders of.
const Map<SuggestionKind, String> suggestionEventTypes = {
  SuggestionKind.watering: 'watering',
  SuggestionKind.fertilizing: 'fertilizing',
  SuggestionKind.pruning: 'pruning',
  SuggestionKind.repotting: 'repotting',
  SuggestionKind.pestCheck: 'inspection',
  SuggestionKind.misting: 'misting',
  SuggestionKind.protectFromCold: 'protect',
  SuggestionKind.moveOutdoors: 'move outdoors',
};

class ReminderSuggestion {
  final SuggestionKind kind;
  final int frequencyQuantity;
  final FrequencyUnit frequencyUnit;
  final DateTime start;
  final DateTime? end;
  // The season the suggestion is for, when it changes with the seasons
  final Season? season;

  const ReminderSuggestion({
    required this.kind,
    required this.frequencyQuantity,
    required this.frequencyUnit,
    required this.start,
    this.end,
    this.season,
  });

  /// Whether [day] is within the suggestion dates.
  bool covers(DateTime day) =>
      !day.isBefore(start) && (end == null || !day.isAfter(end!));
}

/// A part of the coming year in one season.
class SeasonPeriod {
  final DateTime start;
  final DateTime end;
  final Season season;

  const SeasonPeriod(this.start, this.end, this.season);
}

/// The seasons of the year starting on [today] at [latitude], outside the
/// tropics, where seasons follow the calendar: the rest of the current
/// season, then each season until the day before a year from today.
List<SeasonPeriod> seasonPeriods(DateTime today, double latitude) {
  DateTime day = DateTime(today.year, today.month, today.day);
  DateTime yearEnd = DateTime(day.year + 1, day.month, day.day)
      .subtract(const Duration(days: 1));
  List<SeasonPeriod> periods = [];
  DateTime start = day;
  Season season = Weather.seasonFor(day, latitude);
  DateTime month = DateTime(day.year, day.month + 1, 1);
  while (!month.isAfter(yearEnd)) {
    Season next = Weather.seasonFor(month, latitude);
    if (next != season) {
      periods.add(
          SeasonPeriod(start, month.subtract(const Duration(days: 1)), season));
      start = month;
      season = next;
    }
    month = DateTime(month.year, month.month + 1, 1);
  }
  periods.add(SeasonPeriod(start, yearEnd, season));
  return periods;
}

/// A suggestion per season of the coming year, with the frequency in days
/// of each season, joining the seasons with the same frequency. Null when
/// the seasons are not known by the calendar or do not change it.
List<ReminderSuggestion>? _bySeason(SuggestionKind kind, DateTime today,
    double? latitude, int Function(Season) daysIn) {
  if (latitude == null || latitude.abs() < 23.5) {
    return null;
  }
  List<ReminderSuggestion> result = [];
  for (SeasonPeriod period in seasonPeriods(today, latitude)) {
    int days = daysIn(period.season);
    ReminderSuggestion? last = result.isEmpty ? null : result.last;
    if (last != null && last.frequencyQuantity == days) {
      result.last = ReminderSuggestion(
        kind: kind,
        frequencyQuantity: days,
        frequencyUnit: FrequencyUnit.days,
        start: last.start,
        end: period.end,
        season: last.season,
      );
    } else {
      result.add(ReminderSuggestion(
        kind: kind,
        frequencyQuantity: days,
        frequencyUnit: FrequencyUnit.days,
        start: period.start,
        end: period.end,
        season: period.season,
      ));
    }
  }
  return result.length < 2 ? null : result;
}

/// What the schedule texts of a species mean, read by rules or by the AI.
class ScheduleHints {
  // Fertilizer: every [quantity] [unit]
  final int? fertilizerQuantity;
  final FrequencyUnit? fertilizerUnit;
  // Pruning: month 1-12
  final int? pruningMonth;
  final int? repottingYears;
  final int? repottingMonth;

  const ScheduleHints({
    this.fertilizerQuantity,
    this.fertilizerUnit,
    this.pruningMonth,
    this.repottingYears,
    this.repottingMonth,
  });

  /// The schedule stored in the categories that tell when to do each care.
  factory ScheduleHints.fromValues(Map<String, CareValue> values) {
    int? read(String key, int min, int max) {
      double? v = values[key]?.value;
      return v == null || v.round() < min || v.round() > max ? null : v.round();
    }

    int? fertilizerDays = read('fertilizer_every', 1, 365);
    (int, FrequencyUnit)? fertilizer =
        fertilizerDays == null ? null : frequencyOfDays(fertilizerDays);
    return ScheduleHints(
      fertilizerQuantity: fertilizer?.$1,
      fertilizerUnit: fertilizer?.$2,
      pruningMonth: read('pruning_month', 1, 12),
      repottingYears: read('repotting_years', 1, 10),
      repottingMonth: read('repotting_month', 1, 12),
    );
  }

  /// The values to store in the schedule categories, by key.
  Map<String, CareValue> toValues({bool estimated = false}) {
    int? fertilizerDays = fertilizerQuantity == null || fertilizerUnit == null
        ? null
        : fertilizerQuantity! *
            switch (fertilizerUnit!) {
              FrequencyUnit.days => 1,
              FrequencyUnit.weeks => 7,
              FrequencyUnit.months => 30,
              FrequencyUnit.years => 365,
            };
    CareValue value(int n) =>
        CareValue(value: n.toDouble(), estimated: estimated);
    return {
      if (fertilizerDays != null)
        'fertilizer_every': value(fertilizerDays.clamp(1, 365)),
      if (pruningMonth != null) 'pruning_month': value(pruningMonth!),
      if (repottingYears != null) 'repotting_years': value(repottingYears!),
      if (repottingMonth != null) 'repotting_month': value(repottingMonth!),
    };
  }

  bool get isEmpty =>
      fertilizerQuantity == null &&
      pruningMonth == null &&
      repottingYears == null &&
      repottingMonth == null;

  ScheduleHints merge(ScheduleHints other) => ScheduleHints(
        fertilizerQuantity: fertilizerQuantity ?? other.fertilizerQuantity,
        fertilizerUnit: fertilizerUnit ?? other.fertilizerUnit,
        pruningMonth: pruningMonth ?? other.pruningMonth,
        repottingYears: repottingYears ?? other.repottingYears,
        repottingMonth: repottingMonth ?? other.repottingMonth,
      );
}

/// [days] in the largest unit that divides them: months of 30 days,
/// weeks or days.
(int, FrequencyUnit) frequencyOfDays(int days) {
  if (days >= 30 && days % 30 == 0) {
    return (days ~/ 30, FrequencyUnit.months);
  }
  if (days >= 7 && days % 7 == 0) {
    return (days ~/ 7, FrequencyUnit.weeks);
  }
  return (days, FrequencyUnit.days);
}

/// Reads the usual wordings, in Spanish and English, of the fertilizer,
/// pruning and repotting texts.
ScheduleHints readScheduleTexts(
    Map<String, CareValue> values, double? latitude) {
  String text(String key) => (values[key]?.text ?? '').toLowerCase();
  String fertilizer = text('fertilizer');
  String pruning = text('pruning');
  String repotting = text('repotting');

  (int, FrequencyUnit)? frequency = _readFrequency(fertilizer);
  RegExpMatch? years =
      RegExp(r'(?:cada|every)\s+(\d+)(?:\s*[-–a]\s*\d+)?\s*(?:años|year)')
          .firstMatch(repotting);
  int? repottingYears = years != null
      ? int.parse(years.group(1)!)
      : RegExp(r'anual|cada año|every year|yearly|annually').hasMatch(repotting)
          ? 1
          : null;

  return ScheduleHints(
    fertilizerQuantity: frequency?.$1,
    fertilizerUnit: frequency?.$2,
    pruningMonth: _readMonth(pruning, latitude),
    repottingYears: repottingYears,
    repottingMonth: _readMonth(repotting, latitude),
  );
}

(int, FrequencyUnit)? _readFrequency(String text) {
  RegExpMatch? every = RegExp(
          r'(?:cada|every)\s+(\d+)\s*(d[ií]as?|days?|semanas?|weeks?|mes(?:es)?|months?)')
      .firstMatch(text);
  if (every != null) {
    String unit = every.group(2)!;
    FrequencyUnit frequency = unit.startsWith('d')
        ? FrequencyUnit.days
        : unit.startsWith('s') || unit.startsWith('w')
            ? FrequencyUnit.weeks
            : FrequencyUnit.months;
    return (int.parse(every.group(1)!), frequency);
  }
  if (RegExp(
          r'quincenal|cada dos semanas|every (?:two|other) weeks?|biweekly|fortnight')
      .hasMatch(text)) {
    return (2, FrequencyUnit.weeks);
  }
  if (RegExp(r'semanal|cada semana|weekly|every week').hasMatch(text)) {
    return (1, FrequencyUnit.weeks);
  }
  if (RegExp(r'mensual|al mes|cada mes|monthly|a month|every month')
      .hasMatch(text)) {
    return (1, FrequencyUnit.months);
  }
  return null;
}

const List<List<String>> _monthNames = [
  ['enero', 'january'],
  ['febrero', 'february'],
  ['marzo', 'march'],
  ['abril', 'april'],
  ['mayo', 'may'],
  ['junio', 'june'],
  ['julio', 'july'],
  ['agosto', 'august'],
  ['septiembre', 'september'],
  ['octubre', 'october'],
  ['noviembre', 'november'],
  ['diciembre', 'december'],
];

int? _readMonth(String text, double? latitude) {
  for (int i = 0; i < 12; i++) {
    if (_monthNames[i].any((name) => RegExp('\\b$name\\b').hasMatch(text))) {
      return i + 1;
    }
  }
  bool south = (latitude ?? 0) < 0;
  // First month of each season in the northern hemisphere
  for ((String, int) season in [
    (r'primavera|spring', 3),
    (r'verano|summer', 6),
    (r'otoño|autumn|fall', 9),
    (r'invierno|winter', 12),
  ]) {
    if (RegExp(season.$1).hasMatch(text)) {
      int month = season.$2;
      return south ? (month + 5) % 12 + 1 : month;
    }
  }
  return null;
}

/// The next first day of [month], today included.
DateTime nextMonthStart(DateTime today, int month) {
  DateTime date = DateTime(today.year, month, 1);
  if (date.isBefore(DateTime(today.year, today.month, 1))) {
    date = DateTime(today.year + 1, month, 1);
  }
  return date.isBefore(today) ? today : date;
}

/// First month of spring and of autumn at [latitude].
(int, int) _springAndAutumn(double? latitude) =>
    (latitude ?? 0) < 0 ? (9, 3) : (3, 9);

/// Reminders that fit the care of a plant, the season and its location.
List<ReminderSuggestion> suggestReminders({
  required DateTime today,
  required Plant plant,
  SpeciesCareData? care,
  required Map<String, CareValue> values,
  Season? season,
  double? latitude,
  ScheduleHints hints = const ScheduleHints(),
}) {
  DateTime day = DateTime(today.year, today.month, today.day);
  // The schedule categories win over what was read from the texts
  hints = ScheduleHints.fromValues(values).merge(hints);
  bool tropical = latitude != null && latitude.abs() < 23.5;
  (int, int) seasons = _springAndAutumn(latitude);
  List<ReminderSuggestion> result = [];

  // Watering of each season, or of the current one
  int? days = wateringDays(values, season);
  if (days != null) {
    result.addAll(_bySeason(SuggestionKind.watering, day, latitude,
            (s) => wateringDays(values, s)!) ??
        [
          ReminderSuggestion(
            kind: SuggestionKind.watering,
            frequencyQuantity: days,
            frequencyUnit: FrequencyUnit.days,
            start: day,
          )
        ]);
  }

  // Fertilizer during the growing season
  if (values['fertilizer'] != null || values['fertilizer_every'] != null) {
    bool growing = tropical ||
        season == null ||
        season == Season.spring ||
        season == Season.summer;
    DateTime start = growing ? day : nextMonthStart(day, seasons.$1);
    result.add(ReminderSuggestion(
      kind: SuggestionKind.fertilizing,
      frequencyQuantity: hints.fertilizerQuantity ?? 1,
      frequencyUnit: hints.fertilizerUnit ?? FrequencyUnit.months,
      start: start,
      end: tropical
          ? null
          : nextMonthStart(start, seasons.$2).subtract(const Duration(days: 1)),
    ));
  }

  if (values['pruning'] != null || hints.pruningMonth != null) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.pruning,
      frequencyQuantity: 1,
      frequencyUnit: FrequencyUnit.years,
      start: nextMonthStart(day, hints.pruningMonth ?? seasons.$1),
    ));
  }

  if (values['repotting'] != null ||
      hints.repottingYears != null ||
      hints.repottingMonth != null) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.repotting,
      frequencyQuantity: hints.repottingYears ?? 2,
      frequencyUnit: FrequencyUnit.years,
      start: nextMonthStart(day, hints.repottingMonth ?? seasons.$1),
    ));
  }

  if (values['common_pests'] != null) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.pestCheck,
      frequencyQuantity: 2,
      frequencyUnit: FrequencyUnit.weeks,
      start: day,
    ));
  }

  // Misting for plants that need a humid air
  double? mistingDays = values['misting_every']?.value;
  double? minHumidity = values['env_humidity']?.value;
  if (mistingDays != null && mistingDays >= 1) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.misting,
      frequencyQuantity: mistingDays.round().clamp(1, 60),
      frequencyUnit: FrequencyUnit.days,
      start: day,
    ));
  } else if ((minHumidity != null && minHumidity > 60) ||
      (minHumidity == null && (care?.humidity ?? 0) >= 7)) {
    // More often when the air is drier
    int mistingIn(Season? s) => s == Season.summer || s == Season.dry ? 3 : 5;
    result.addAll(_bySeason(SuggestionKind.misting, day, latitude, mistingIn) ??
        [
          ReminderSuggestion(
            kind: SuggestionKind.misting,
            frequencyQuantity: mistingIn(season),
            frequencyUnit: FrequencyUnit.days,
            start: day,
          )
        ]);
  }

  // Outdoor plants that do not withstand the cold of winter
  if (!tropical &&
      plant.location == PlantLocation.outdoor &&
      care?.tempMin != null &&
      care!.tempMin! >= 10) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.protectFromCold,
      frequencyQuantity: 1,
      frequencyUnit: FrequencyUnit.years,
      start: nextMonthStart(day, seasons.$2),
    ));
    result.add(ReminderSuggestion(
      kind: SuggestionKind.moveOutdoors,
      frequencyQuantity: 1,
      frequencyUnit: FrequencyUnit.years,
      start: nextMonthStart(day, seasons.$1),
    ));
  }
  return result;
}

/// Days between waterings in [season]: the summer or winter value, their
/// average in spring, autumn or an unknown season, summer's in the dry
/// season and winter's in the rainy one.
int? wateringDays(Map<String, CareValue> values, Season? season) {
  double? summer = values['watering_summer']?.value;
  double? winter = values['watering_winter']?.value;
  if (summer == null && winter == null) {
    return null;
  }
  double days = switch (season) {
        Season.summer || Season.dry => summer ?? winter,
        Season.winter || Season.rainy => winter ?? summer,
        _ => summer != null && winter != null
            ? (summer + winter) / 2
            : summer ?? winter,
      } ??
      1;
  return days.round().clamp(1, 365);
}
