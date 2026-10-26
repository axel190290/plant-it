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

  const ReminderSuggestion({
    required this.kind,
    required this.frequencyQuantity,
    required this.frequencyUnit,
    required this.start,
    this.end,
  });
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

  ScheduleHints merge(ScheduleHints other) => ScheduleHints(
        fertilizerQuantity: fertilizerQuantity ?? other.fertilizerQuantity,
        fertilizerUnit: fertilizerUnit ?? other.fertilizerUnit,
        pruningMonth: pruningMonth ?? other.pruningMonth,
        repottingYears: repottingYears ?? other.repottingYears,
        repottingMonth: repottingMonth ?? other.repottingMonth,
      );
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
  bool tropical = latitude != null && latitude.abs() < 23.5;
  (int, int) seasons = _springAndAutumn(latitude);
  List<ReminderSuggestion> result = [];

  // Watering of the current season
  int? days = wateringDays(values, season);
  if (days != null) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.watering,
      frequencyQuantity: days,
      frequencyUnit: FrequencyUnit.days,
      start: day,
    ));
  }

  // Fertilizer during the growing season
  if (values['fertilizer'] != null) {
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

  if (values['pruning'] != null) {
    result.add(ReminderSuggestion(
      kind: SuggestionKind.pruning,
      frequencyQuantity: 1,
      frequencyUnit: FrequencyUnit.years,
      start: nextMonthStart(day, hints.pruningMonth ?? seasons.$1),
    ));
  }

  if (values['repotting'] != null) {
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
  double? minHumidity = values['env_humidity']?.value;
  if ((minHumidity != null && minHumidity > 60) ||
      (minHumidity == null && (care?.humidity ?? 0) >= 7)) {
    bool dry = season == Season.summer || season == Season.dry;
    result.add(ReminderSuggestion(
      kind: SuggestionKind.misting,
      frequencyQuantity: dry ? 3 : 5,
      frequencyUnit: FrequencyUnit.days,
      start: day,
    ));
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
