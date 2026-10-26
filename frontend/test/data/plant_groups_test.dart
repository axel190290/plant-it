import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/plant_groups.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/domain/models/weather.dart';

void main() {
  test('plantGroupFor prefers the species, then the genus, then the family',
      () {
    expect(plantGroupFor('Dracaena trifasciata', 'Asparagaceae')!.id,
        'succulents');
    expect(
        plantGroupFor('Dracaena marginata', 'Asparagaceae')!.id, 'dracaenas');
    expect(
        plantGroupFor('Zamioculcas zamiifolia', 'Araceae')!.id, 'zamioculcas');
    expect(plantGroupFor('Monstera deliciosa Liebm.', 'Araceae')!.id, 'aroids');
    expect(
        plantGroupFor('Nephrolepis exaltata', 'Nephrolepidaceae')!.id, 'ferns');
    expect(plantGroupFor('Quercus robur', 'Fagaceae'), isNull);
    expect(plantGroupFor('Quercus robur', null), isNull);
  });

  test('PlantGroup.values flips the months in the southern hemisphere', () {
    PlantGroup cacti = plantGroupById('cacti')!;
    Map<String, CareValue> north = cacti.values();
    expect(north['watering_summer']!.value, 14);
    expect(north['watering_summer']!.source, 'group:cacti');
    expect(north['dormancy_months']!.value, 11);
    expect(north['dormancy_months']!.maxValue, 2);
    Map<String, CareValue> south = cacti.values(southernHemisphere: true);
    expect(south['dormancy_months']!.value, 5);
    expect(south['dormancy_months']!.maxValue, 8);
    expect(south['repotting_month']!.value, 9);
    expect(PlantGroup.idOfSource('group:cacti'), 'cacti');
    expect(PlantGroup.idOfSource(null), isNull);
  });

  test('CareSources keeps the plant group', () {
    CareSources sources = CareSources.decode(
        const CareSources(species: 'gbif', group: 'ferns').encode())!;
    expect(sources.group, 'ferns');
    expect(sources.species, 'gbif');
  });

  test('monthsOf wraps around the year', () {
    expect(monthsOf(const CareValue(value: 11, maxValue: 2)), {11, 12, 1, 2});
    expect(monthsOf(const CareValue(value: 4, maxValue: 6)), {4, 5, 6});
    expect(monthsOf(const CareValue(value: 3)), {3});
    expect(monthsOf(null), isEmpty);
    expect(monthsOf(const CareValue(value: 13, maxValue: 2)), isEmpty);
  });

  test('suggestReminders waters less and does not fertilize while resting', () {
    List<ReminderSuggestion> suggestions = suggestReminders(
      today: DateTime(2026, 10, 26),
      plant: const Plant(
          id: 1,
          name: 'Cactus',
          species: 1,
          location: PlantLocation.indoor,
          avatarMode: AvatarMode.none),
      values: plantGroupById('cacti')!.values(),
      season: Season.autumn,
      latitude: 40,
    );
    List<ReminderSuggestion> watering =
        suggestions.where((s) => s.kind == SuggestionKind.watering).toList();
    // Autumn until the rest in November, which lasts until February
    expect(watering.first.dormant, isFalse);
    expect(watering.first.end, DateTime(2026, 10, 31));
    expect(watering[1].dormant, isTrue);
    expect(watering[1].frequencyQuantity, 30);
    expect(watering[1].start, DateTime(2026, 11, 1));
    expect(watering[1].end, DateTime(2027, 2, 28));
    ReminderSuggestion fertilizing =
        suggestions.firstWhere((s) => s.kind == SuggestionKind.fertilizing);
    expect(fertilizing.start, DateTime(2026, 10, 26));
    expect(fertilizing.end, DateTime(2026, 10, 31));
    expect(fertilizing.frequencyQuantity, 1);
    expect(fertilizing.frequencyUnit, FrequencyUnit.months);
  });

  test('suggestReminders splits the watering by the rest in the tropics', () {
    List<ReminderSuggestion> watering = suggestReminders(
      today: DateTime(2026, 3, 10),
      plant: const Plant(
          id: 1, name: 'Rosa', species: 1, avatarMode: AvatarMode.none),
      values: {
        'watering_summer': const CareValue(value: 4),
        'dormancy_months': const CareValue(value: 6, maxValue: 7),
      },
      season: Season.dry,
      latitude: 10,
    ).where((s) => s.kind == SuggestionKind.watering).toList();
    expect(watering.map((s) => (s.dormant, s.frequencyQuantity)), [
      (false, 4),
      (true, 8),
      (false, 4),
    ]);
  });
}
