import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';

/// Care categories worth having at hand for each event type, by name.
const Map<String, List<String>> eventTypeCareKeys = {
  'watering': [
    'watering_summer',
    'watering_winter',
    'water_type',
    'watering_method'
  ],
  'fertilizing': ['fertilizer', 'fertilizer_every'],
  'pruning': ['pruning', 'pruning_month'],
  'repotting': ['repotting', 'repotting_years', 'repotting_month', 'substrate'],
  'seeding': ['substrate', basicTemperatureKey],
  'pest': ['common_pests', 'diseases'],
  'inspection': ['common_pests', 'diseases'],
  'treatment': ['diseases', 'common_pests'],
  'misting': ['misting_every', 'env_humidity'],
  'protect': [basicTemperatureKey],
  'move outdoors': [basicTemperatureKey, 'light_hours'],
};

/// A note with the care of a species that matters for the events of
/// [typeNames], one category per line, or null if it has none.
String? careNote(L l, Iterable<String> typeNames, List<CareField> fields,
    Map<String, CareValue> values, SpeciesCareData? care) {
  List<String> keys = [
    for (String name in typeNames) ...?eventTypeCareKeys[name],
  ];
  List<String> lines = [];
  for (String key in keys.toSet()) {
    CareField? field = fields.where((f) => f.key == key).firstOrNull;
    if (field == null || !field.enabled) continue;
    String? text;
    if (key == basicTemperatureKey) {
      int? min = care?.tempMin;
      int? max = care?.tempMax;
      text = min != null && max != null
          ? "$min - $max °C"
          : min != null
              ? "${l.min} $min °C"
              : max != null
                  ? "${l.max} $max °C"
                  : null;
    } else if (values[key] != null) {
      text = formatCareValue(l, field, values[key]!);
    }
    if (text != null && text.trim().isNotEmpty) {
      lines.add("${careFieldName(l, field)}: $text");
    }
  }
  return lines.isEmpty ? null : lines.join('\n');
}
