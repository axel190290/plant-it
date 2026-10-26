import 'package:plant_it/domain/models/plant_groups.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// The name of a plant group in the language of the app.
String plantGroupName(L l, String id) => switch (id) {
      'cacti' => l.plantGroupCacti,
      'succulents' => l.plantGroupSucculents,
      'zamioculcas' => l.plantGroupZamioculcas,
      'aroids' => l.plantGroupAroids,
      'ferns' => l.plantGroupFerns,
      'orchids' => l.plantGroupOrchids,
      'airPlants' => l.plantGroupAirPlants,
      'bromeliads' => l.plantGroupBromeliads,
      'palms' => l.plantGroupPalms,
      'prayerPlants' => l.plantGroupPrayerPlants,
      'ficus' => l.plantGroupFicus,
      'dracaenas' => l.plantGroupDracaenas,
      'herbs' => l.plantGroupHerbs,
      'roses' => l.plantGroupRoses,
      'begonias' => l.plantGroupBegonias,
      'gesneriads' => l.plantGroupGesneriads,
      'citrus' => l.plantGroupCitrus,
      'carnivorous' => l.plantGroupCarnivorous,
      _ => id,
    };

/// "Typical value of aroids" for a value of a plant group, else null.
String? typicalValueNote(L l, String? source) {
  String? id = PlantGroup.idOfSource(source);
  return id == null ? null : l.typicalValueOf(plantGroupName(l, id));
}
