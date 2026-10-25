import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// The name of a care field: translated for built-in fields, as written by
/// the user for the others.
String careFieldName(L l, CareField field) => switch (field.key) {
      'light_lux' => l.careFieldLightLux,
      'light_hours' => l.careFieldLightHours,
      'env_humidity' => l.careFieldEnvHumidity,
      'watering_summer' => l.careFieldWateringSummer,
      'watering_winter' => l.careFieldWateringWinter,
      'soil_moisture' => l.careFieldSoilMoisture,
      'conductivity' => l.careFieldConductivity,
      'water_type' => l.careFieldWaterType,
      'watering_method' => l.careFieldWateringMethod,
      'substrate' => l.careFieldSubstrate,
      'fertilizer' => l.careFieldFertilizer,
      'pruning' => l.careFieldPruning,
      'repotting' => l.careFieldRepotting,
      'flowering_season' => l.careFieldFloweringSeason,
      'dormancy_season' => l.careFieldDormancySeason,
      'common_pests' => l.careFieldCommonPests,
      'diseases' => l.careFieldDiseases,
      'toxicity' => l.careFieldToxicity,
      _ => field.name ?? field.key ?? '',
    };

String _number(double n) =>
    n == n.roundToDouble() ? n.round().toString() : n.toStringAsFixed(1);

/// The value as shown to the user, or null if it is empty.
String? formatCareValue(L l, CareField field, CareValue value) {
  if (value.isEmpty) {
    return null;
  }
  String withUnit(String number) {
    if (field.unit == 'days') {
      return l.everyNDays(number);
    }
    if (field.unit == null || field.unit!.isEmpty) {
      return number;
    }
    return field.unit == '%' ? '$number%' : '$number ${field.unit}';
  }

  switch (field.type) {
    case CareFieldType.number:
      return value.value == null ? null : withUnit(_number(value.value!));
    case CareFieldType.range:
      if (value.value != null && value.maxValue != null) {
        return withUnit(
            '${_number(value.value!)} - ${_number(value.maxValue!)}');
      }
      if (value.value != null) {
        return '${l.min} ${withUnit(_number(value.value!))}';
      }
      return '${l.max} ${withUnit(_number(value.maxValue!))}';
    case CareFieldType.text:
    case CareFieldType.choice:
      return value.text;
  }
}

/// The enabled care fields that have a value, one per row.
class CareValuesSection extends StatelessWidget {
  final List<CareField> fields;
  final Map<int, CareValue> values;
  final String emptyText;

  const CareValuesSection({
    super.key,
    required this.fields,
    required this.values,
    required this.emptyText,
  });

  /// Converts values of built-in fields by key, as given by the external
  /// data sources, to values by field id.
  static Map<int, CareValue> valuesByKey(
      List<CareField> fields, Map<String, CareValue> byKey) {
    return {
      for (CareField field in fields)
        if (field.key != null && byKey.containsKey(field.key))
          field.id: byKey[field.key]!
    };
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    List<(CareField, String, bool)> rows = [];
    for (CareField field in fields) {
      if (!field.enabled || !values.containsKey(field.id)) continue;
      String? text = formatCareValue(l, field, values[field.id]!);
      if (text != null) {
        rows.add((field, text, values[field.id]!.estimated));
      }
    }
    if (rows.isEmpty) {
      return Text(emptyText, style: Theme.of(context).textTheme.bodyLarge);
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  careFieldName(l, row.$1),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child:
                    Text(row.$2, style: Theme.of(context).textTheme.bodyLarge),
              ),
              if (row.$3)
                Tooltip(
                  message: l.estimatedByAi,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6, top: 3),
                    child: Icon(LucideIcons.sparkles,
                        size: 14, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
