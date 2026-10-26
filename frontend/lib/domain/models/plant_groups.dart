import 'package:drift/drift.dart' show Value;
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';

/// The typical care of a group of plants, used when no data source gives
/// the care of a species. Months are those of the northern hemisphere.
class PlantGroup {
  final String id;
  final Set<String> families;
  final Set<String> genera;
  // Species, as "genus epithet" in lower case, that belong to the group
  // although their genus or family belongs to another
  final Set<String> species;
  final int? light;
  final int? humidity;
  final int? tempMin;
  final int? tempMax;
  final int? wateringSummer;
  final int? wateringWinter;
  final int? mistingEvery;
  final int? fertilizerEvery;
  final int? pruningMonth;
  final int? repottingYears;
  final int? repottingMonth;
  final (int, int)? flowering;
  final (int, int)? dormancy;

  const PlantGroup(
    this.id, {
    this.families = const {},
    this.genera = const {},
    this.species = const {},
    this.light,
    this.humidity,
    this.tempMin,
    this.tempMax,
    this.wateringSummer,
    this.wateringWinter,
    this.mistingEvery,
    this.fertilizerEvery,
    this.pruningMonth,
    this.repottingYears,
    this.repottingMonth,
    this.flowering,
    this.dormancy,
  });

  String get source => '$sourcePrefix$id';

  static const String sourcePrefix = 'group:';

  /// The group id of a value [source], if it comes from a group.
  static String? idOfSource(String? source) =>
      source != null && source.startsWith(sourcePrefix)
          ? source.substring(sourcePrefix.length)
          : null;

  /// The care values of the group, by key, with the months of the
  /// hemisphere of the place.
  Map<String, CareValue> values({bool southernHemisphere = false}) {
    int month(int m) => southernHemisphere ? (m + 5) % 12 + 1 : m;
    CareValue number(int n) => CareValue(value: n.toDouble(), source: source);
    CareValue months((int, int) range) => CareValue(
        value: month(range.$1).toDouble(),
        maxValue: month(range.$2).toDouble(),
        source: source);
    return {
      if (wateringSummer != null) 'watering_summer': number(wateringSummer!),
      if (wateringWinter != null) 'watering_winter': number(wateringWinter!),
      if (mistingEvery != null) 'misting_every': number(mistingEvery!),
      if (fertilizerEvery != null) 'fertilizer_every': number(fertilizerEvery!),
      if (pruningMonth != null) 'pruning_month': number(month(pruningMonth!)),
      if (repottingYears != null) 'repotting_years': number(repottingYears!),
      if (repottingMonth != null)
        'repotting_month': number(month(repottingMonth!)),
      if (flowering != null) 'flowering_months': months(flowering!),
      if (dormancy != null) 'dormancy_months': months(dormancy!),
    };
  }

  /// The basic care of the group.
  SpeciesCareCompanion get care => SpeciesCareCompanion(
        light: Value(light),
        humidity: Value(humidity),
        tempMin: Value(tempMin),
        tempMax: Value(tempMax),
      );
}

const Set<String> _fernFamilies = {
  'Polypodiaceae',
  'Pteridaceae',
  'Nephrolepidaceae',
  'Aspleniaceae',
  'Dryopteridaceae',
  'Davalliaceae',
  'Athyriaceae',
  'Blechnaceae',
  'Lomariopsidaceae',
  'Dennstaedtiaceae',
  'Osmundaceae',
  'Cyatheaceae',
  'Thelypteridaceae',
};

/// The groups known by the app.
const List<PlantGroup> plantGroups = [
  PlantGroup('cacti',
      families: {'Cactaceae'},
      light: 9,
      humidity: 3,
      tempMin: 5,
      tempMax: 35,
      wateringSummer: 14,
      wateringWinter: 30,
      fertilizerEvery: 30,
      repottingYears: 3,
      repottingMonth: 3,
      flowering: (4, 6),
      dormancy: (11, 2)),
  PlantGroup('succulents',
      families: {'Crassulaceae', 'Aizoaceae'},
      genera: {
        'Aloe',
        'Haworthia',
        'Haworthiopsis',
        'Gasteria',
        'Sansevieria',
        'Agave',
        'Euphorbia',
        'Portulacaria',
        'Curio',
        'Adenium',
        'Pachypodium',
      },
      species: {'dracaena trifasciata', 'senecio rowleyanus'},
      light: 8,
      humidity: 3,
      tempMin: 5,
      tempMax: 32,
      wateringSummer: 10,
      wateringWinter: 25,
      fertilizerEvery: 30,
      repottingYears: 2,
      repottingMonth: 3,
      dormancy: (12, 2)),
  PlantGroup('zamioculcas',
      genera: {'Zamioculcas'},
      light: 5,
      humidity: 4,
      tempMin: 15,
      tempMax: 30,
      wateringSummer: 14,
      wateringWinter: 30,
      fertilizerEvery: 30,
      repottingYears: 3,
      repottingMonth: 3),
  PlantGroup('aroids',
      families: {'Araceae'},
      light: 6,
      humidity: 7,
      tempMin: 15,
      tempMax: 30,
      wateringSummer: 7,
      wateringWinter: 14,
      mistingEvery: 4,
      fertilizerEvery: 21,
      pruningMonth: 3,
      repottingYears: 2,
      repottingMonth: 3),
  PlantGroup('ferns',
      families: _fernFamilies,
      light: 4,
      humidity: 8,
      tempMin: 12,
      tempMax: 28,
      wateringSummer: 3,
      wateringWinter: 7,
      mistingEvery: 2,
      fertilizerEvery: 30,
      repottingYears: 2,
      repottingMonth: 3),
  PlantGroup('orchids',
      families: {'Orchidaceae'},
      light: 6,
      humidity: 6,
      tempMin: 15,
      tempMax: 30,
      wateringSummer: 7,
      wateringWinter: 14,
      mistingEvery: 3,
      fertilizerEvery: 14,
      repottingYears: 2,
      repottingMonth: 4,
      flowering: (1, 4)),
  PlantGroup('airPlants',
      genera: {'Tillandsia'},
      light: 7,
      humidity: 6,
      tempMin: 10,
      tempMax: 32,
      wateringSummer: 7,
      wateringWinter: 14,
      mistingEvery: 3,
      fertilizerEvery: 30),
  PlantGroup('bromeliads',
      families: {'Bromeliaceae'},
      light: 6,
      humidity: 6,
      tempMin: 12,
      tempMax: 30,
      wateringSummer: 7,
      wateringWinter: 14,
      mistingEvery: 3,
      fertilizerEvery: 30,
      repottingYears: 3,
      repottingMonth: 3),
  PlantGroup('palms',
      families: {'Arecaceae'},
      light: 7,
      humidity: 5,
      tempMin: 10,
      tempMax: 32,
      wateringSummer: 5,
      wateringWinter: 10,
      fertilizerEvery: 30,
      repottingYears: 3,
      repottingMonth: 4),
  PlantGroup('prayerPlants',
      families: {'Marantaceae'},
      light: 4,
      humidity: 8,
      tempMin: 16,
      tempMax: 28,
      wateringSummer: 5,
      wateringWinter: 10,
      mistingEvery: 2,
      fertilizerEvery: 21,
      repottingYears: 2,
      repottingMonth: 4),
  PlantGroup('ficus',
      genera: {'Ficus'},
      light: 7,
      humidity: 5,
      tempMin: 13,
      tempMax: 30,
      wateringSummer: 7,
      wateringWinter: 14,
      fertilizerEvery: 30,
      pruningMonth: 3,
      repottingYears: 2,
      repottingMonth: 3),
  PlantGroup('dracaenas',
      genera: {
        'Dracaena',
        'Yucca',
        'Chlorophytum',
        'Cordyline',
        'Aspidistra',
        'Beaucarnea'
      },
      light: 6,
      humidity: 5,
      tempMin: 12,
      tempMax: 30,
      wateringSummer: 7,
      wateringWinter: 14,
      fertilizerEvery: 30,
      repottingYears: 2,
      repottingMonth: 3),
  PlantGroup('herbs',
      families: {'Lamiaceae'},
      light: 9,
      humidity: 4,
      tempMin: 5,
      tempMax: 32,
      wateringSummer: 3,
      wateringWinter: 10,
      fertilizerEvery: 30,
      pruningMonth: 3,
      repottingYears: 1,
      repottingMonth: 3,
      flowering: (6, 8)),
  PlantGroup('roses',
      genera: {'Rosa'},
      light: 9,
      humidity: 5,
      tempMin: -10,
      tempMax: 35,
      wateringSummer: 3,
      wateringWinter: 10,
      fertilizerEvery: 21,
      pruningMonth: 2,
      repottingYears: 2,
      repottingMonth: 2,
      flowering: (5, 9),
      dormancy: (12, 2)),
  PlantGroup('begonias',
      families: {'Begoniaceae'},
      light: 5,
      humidity: 6,
      tempMin: 15,
      tempMax: 28,
      wateringSummer: 5,
      wateringWinter: 10,
      fertilizerEvery: 14,
      repottingYears: 1,
      repottingMonth: 3),
  PlantGroup('gesneriads',
      families: {'Gesneriaceae'},
      light: 6,
      humidity: 6,
      tempMin: 16,
      tempMax: 27,
      wateringSummer: 5,
      wateringWinter: 8,
      fertilizerEvery: 14,
      repottingYears: 1,
      repottingMonth: 3),
  PlantGroup('citrus',
      genera: {'Citrus'},
      light: 9,
      humidity: 5,
      tempMin: 5,
      tempMax: 35,
      wateringSummer: 4,
      wateringWinter: 10,
      fertilizerEvery: 21,
      pruningMonth: 3,
      repottingYears: 3,
      repottingMonth: 3,
      flowering: (3, 5)),
  PlantGroup('carnivorous',
      families: {
        'Droseraceae',
        'Sarraceniaceae',
        'Nepenthaceae',
        'Lentibulariaceae'
      },
      light: 8,
      humidity: 7,
      tempMin: 5,
      tempMax: 30,
      wateringSummer: 2,
      wateringWinter: 5,
      repottingYears: 2,
      repottingMonth: 3,
      dormancy: (11, 2)),
];

/// The group of a species: by its species, else its genus, else its
/// family.
PlantGroup? plantGroupFor(String scientificName, String? family) {
  List<String> words = scientificName.trim().split(RegExp(r'\s+'));
  String genus = words.first;
  String species =
      words.length > 1 ? '${words[0]} ${words[1]}'.toLowerCase() : '';
  for (PlantGroup group in plantGroups) {
    if (group.species.contains(species)) return group;
  }
  for (PlantGroup group in plantGroups) {
    if (group.genera.contains(genus)) return group;
  }
  if (family == null) return null;
  for (PlantGroup group in plantGroups) {
    if (group.families.contains(family.trim())) return group;
  }
  return null;
}

PlantGroup? plantGroupById(String? id) =>
    plantGroups.where((g) => g.id == id).firstOrNull;
