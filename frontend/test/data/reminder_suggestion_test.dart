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
      for (ReminderSuggestion s in suggestions) s.kind: s
    };
    expect(byKind.keys.toSet(), SuggestionKind.values.toSet());
    expect(byKind[SuggestionKind.watering]!.frequencyQuantity, 14);
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
