import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/domain/models/weather.dart';

Plant _plant(String? location) => Plant(
      id: 1,
      name: 'Monstera',
      species: 1,
      location: location,
      avatarMode: AvatarMode.none,
    );

SpeciesCareData _care({int? tempMin, int? humidity}) =>
    SpeciesCareData(species: 1, tempMin: tempMin, humidity: humidity);

void main() {
  test('wateringDays follows the season', () {
    Map<String, CareValue> values = {
      'watering_summer': const CareValue(value: 7),
      'watering_winter': const CareValue(value: 21),
    };
    expect(wateringDays(values, Season.summer), 7);
    expect(wateringDays(values, Season.winter), 21);
    expect(wateringDays(values, Season.autumn), 14);
    expect(wateringDays(values, Season.dry), 7);
    expect(wateringDays(values, Season.rainy), 21);
    expect(wateringDays(values, null), 14);
    expect(
        wateringDays(
            {'watering_winter': const CareValue(value: 30)}, Season.summer),
        30);
    expect(wateringDays({}, Season.summer), isNull);
  });

  test('readScheduleTexts understands the usual wordings', () {
    ScheduleHints hints = readScheduleTexts({
      'fertilizer':
          const CareValue(text: 'Abono líquido diluido cada 15 días en verano'),
      'pruning': const CareValue(text: 'Poda ligera a finales de invierno'),
      'repotting': const CareValue(text: 'Cada 2-3 años, en primavera'),
    }, 40);
    expect(hints.fertilizerQuantity, 15);
    expect(hints.fertilizerUnit, FrequencyUnit.days);
    expect(hints.pruningMonth, 12);
    expect(hints.repottingYears, 2);
    expect(hints.repottingMonth, 3);

    ScheduleHints english = readScheduleTexts({
      'fertilizer': const CareValue(text: 'Once a month in spring'),
      'pruning': const CareValue(text: 'Prune in March'),
    }, -34);
    expect(english.fertilizerQuantity, 1);
    expect(english.fertilizerUnit, FrequencyUnit.months);
    expect(english.pruningMonth, 3);
    // In the south, spring starts in September
    expect(
        readScheduleTexts({'repotting': const CareValue(text: 'spring')}, -34)
            .repottingMonth,
        9);
  });

  test('suggestReminders builds every suggestion from the care', () {
    DateTime today = DateTime(2026, 10, 26);
    List<ReminderSuggestion> suggestions = suggestReminders(
      today: today,
      plant: _plant(PlantLocation.outdoor),
      care: _care(tempMin: 12, humidity: 8),
      values: {
        'watering_summer': const CareValue(value: 7),
        'watering_winter': const CareValue(value: 21),
        'fertilizer': const CareValue(text: 'mensual'),
        'pruning': const CareValue(text: 'primavera'),
        'repotting': const CareValue(text: 'cada 2 años'),
        'common_pests': const CareValue(text: 'cochinilla'),
      },
      season: Season.autumn,
      latitude: 40,
    );
    Map<SuggestionKind, ReminderSuggestion> byKind = {
      for (ReminderSuggestion s in suggestions.reversed) s.kind: s
    };
    expect(byKind.keys.toSet(), SuggestionKind.values.toSet());
    // Watering changes with the seasons of the coming year
    List<ReminderSuggestion> watering =
        suggestions.where((s) => s.kind == SuggestionKind.watering).toList();
    expect(watering.map((s) => (s.season, s.frequencyQuantity)), [
      (Season.autumn, 14),
      (Season.winter, 21),
      (Season.spring, 14),
      (Season.summer, 7),
      (Season.autumn, 14),
    ]);
    expect(watering[0].start, today);
    expect(watering[0].end, DateTime(2026, 11, 30));
    expect(watering[1].start, DateTime(2026, 12, 1));
    expect(watering[1].end, DateTime(2027, 2, 28));
    expect(watering.last.end, DateTime(2027, 10, 25));
    // Autumn: fertilizer waits for spring and stops before autumn
    expect(byKind[SuggestionKind.fertilizing]!.start, DateTime(2027, 3, 1));
    expect(byKind[SuggestionKind.fertilizing]!.end, DateTime(2027, 8, 31));
    expect(byKind[SuggestionKind.pruning]!.start, DateTime(2027, 3, 1));
    expect(byKind[SuggestionKind.repotting]!.frequencyQuantity, 2);
    expect(byKind[SuggestionKind.misting]!.frequencyQuantity, 5);
    expect(byKind[SuggestionKind.protectFromCold]!.start, DateTime(2027, 9, 1));
    expect(byKind[SuggestionKind.moveOutdoors]!.start, DateTime(2027, 3, 1));
  });

  test('suggestReminders skips cold protection indoors and in the tropics', () {
    DateTime today = DateTime(2026, 10, 26);
    for ((String?, double) place in [
      (PlantLocation.indoor, 40),
      (PlantLocation.outdoor, 10),
    ]) {
      List<ReminderSuggestion> suggestions = suggestReminders(
        today: today,
        plant: _plant(place.$1),
        care: _care(tempMin: 15),
        values: const {},
        latitude: place.$2,
      );
      expect(suggestions, isEmpty);
    }
  });

  test('suggestReminders prefers the schedule categories to the texts', () {
    List<ReminderSuggestion> suggestions = suggestReminders(
      today: DateTime(2026, 4, 10),
      plant: _plant(PlantLocation.indoor),
      values: {
        'fertilizer': const CareValue(text: 'mensual'),
        'fertilizer_every': const CareValue(value: 14),
        'pruning_month': const CareValue(value: 6),
        'repotting_years': const CareValue(value: 3),
        'misting_every': const CareValue(value: 2),
      },
      season: Season.spring,
      latitude: 40,
    );
    Map<SuggestionKind, ReminderSuggestion> byKind = {
      for (ReminderSuggestion s in suggestions) s.kind: s
    };
    expect(byKind[SuggestionKind.fertilizing]!.frequencyQuantity, 2);
    expect(
        byKind[SuggestionKind.fertilizing]!.frequencyUnit, FrequencyUnit.weeks);
    expect(byKind[SuggestionKind.fertilizing]!.start, DateTime(2026, 4, 10));
    expect(byKind[SuggestionKind.pruning]!.start, DateTime(2026, 6, 1));
    expect(byKind[SuggestionKind.repotting]!.frequencyQuantity, 3);
    expect(byKind[SuggestionKind.repotting]!.start, DateTime(2027, 3, 1));
    expect(byKind[SuggestionKind.misting]!.frequencyQuantity, 2);
  });

  test('seasonPeriods covers the coming year by season', () {
    List<SeasonPeriod> south = seasonPeriods(DateTime(2026, 1, 15), -34);
    expect(south.map((p) => p.season), [
      Season.summer,
      Season.autumn,
      Season.winter,
      Season.spring,
      Season.summer,
    ]);
    expect(south.first.end, DateTime(2026, 2, 28));
    expect(south.last.start, DateTime(2026, 12, 1));
    expect(south.last.end, DateTime(2027, 1, 14));
  });

  test(
      'suggestReminders keeps one watering in the tropics or without '
      'change between seasons', () {
    for ((Map<String, CareValue>, double) input in [
      (
        {
          'watering_summer': const CareValue(value: 7),
          'watering_winter': const CareValue(value: 21),
        },
        10
      ),
      ({'watering_summer': const CareValue(value: 7)}, 40),
    ]) {
      List<ReminderSuggestion> watering = suggestReminders(
        today: DateTime(2026, 10, 26),
        plant: _plant(PlantLocation.indoor),
        values: input.$1,
        season: Season.autumn,
        latitude: input.$2,
      ).where((s) => s.kind == SuggestionKind.watering).toList();
      expect(watering.length, 1);
      expect(watering.single.end, isNull);
    }
  });

  test('ScheduleHints round-trips through the schedule categories', () {
    ScheduleHints hints = const ScheduleHints(
      fertilizerQuantity: 1,
      fertilizerUnit: FrequencyUnit.months,
      pruningMonth: 3,
      repottingYears: 2,
    );
    Map<String, CareValue> values = hints.toValues(estimated: true);
    expect(values['fertilizer_every']!.value, 30);
    expect(values['fertilizer_every']!.estimated, isTrue);
    expect(values.containsKey('repotting_month'), isFalse);
    ScheduleHints read = ScheduleHints.fromValues(values);
    expect(read.fertilizerQuantity, 1);
    expect(read.fertilizerUnit, FrequencyUnit.months);
    expect(read.pruningMonth, 3);
    expect(read.repottingYears, 2);
    expect(
        ScheduleHints.fromValues({'pruning_month': const CareValue(value: 13)})
            .isEmpty,
        isTrue);
    expect(frequencyOfDays(10), (10, FrequencyUnit.days));
    expect(frequencyOfDays(21), (3, FrequencyUnit.weeks));
    expect(frequencyOfDays(60), (2, FrequencyUnit.months));
  });

  test('AiCareEstimator.parseSchedule ignores values out of range', () {
    ScheduleHints hints = AiCareEstimator.parseSchedule(
            '{"fertilizer_every": 2, "fertilizer_unit": "weeks", '
            '"pruning_month": 13, "repotting_every_years": 3, '
            '"repotting_month": null}')
        .getOrThrow();
    expect(hints.fertilizerQuantity, 2);
    expect(hints.fertilizerUnit, FrequencyUnit.weeks);
    expect(hints.pruningMonth, isNull);
    expect(hints.repottingYears, 3);
    expect(hints.repottingMonth, isNull);
  });
}
