import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/utils/icons.dart';

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

/// Converts values of built-in fields by key, as given by the external data
/// sources, to values by field id.
Map<int, CareValue> careValuesByFieldId(
    List<CareField> fields, Map<String, CareValue> byKey) {
  return {
    for (CareField field in fields)
      if (field.key != null && byKey.containsKey(field.key))
        field.id: byKey[field.key]!
  };
}

/// Icons offered for the care categories created by the user.
const List<String> customCareFieldIcons = [
  'sprout',
  'leaf',
  'flower',
  'tree_pine',
  'sun',
  'droplet',
  'thermometer',
  'wind',
  'bug',
  'scissors',
  'flask_conical',
  'ruler',
  'heart',
  'star',
  'tag',
  'package_open',
];

IconData careFieldIcon(CareField field) {
  String name = switch (field.key) {
    'light_lux' => 'sun_medium',
    'light_hours' => 'sunrise',
    'env_humidity' => 'droplets',
    'watering_summer' => 'droplet',
    'watering_winter' => 'snowflake',
    'soil_moisture' => 'shovel',
    'conductivity' => 'zap',
    'water_type' => 'glass_water',
    'watering_method' => 'shower_head',
    'substrate' => 'layers',
    'fertilizer' => 'flask_conical',
    'pruning' => 'scissors',
    'repotting' => 'package_open',
    'flowering_season' => 'flower',
    'dormancy_season' => 'moon',
    'common_pests' => 'bug',
    'diseases' => 'shield_alert',
    'toxicity' => 'skull',
    _ => field.icon ?? 'sprout',
  };
  return appIcons[name] ?? LucideIcons.sprout;
}
