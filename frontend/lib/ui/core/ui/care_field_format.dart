import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/utils/icons.dart';

/// The name of a care field: translated for built-in fields, as written by
/// the user for the others.
/// Keys of the categories of the basic care, whose values are stored in
/// the species care and not as care values.
const String basicLightKey = 'basic_light';
const String basicHumidityKey = 'basic_humidity';
const String basicTemperatureKey = 'basic_temperature';
const String basicPhKey = 'basic_ph';

bool isBasicCareField(CareField field) =>
    field.key != null && field.key!.startsWith('basic_');

/// The basic care categories with their default order, icon and state, used
/// when the care fields could not be loaded.
final List<CareField> basicCareFieldPlaceholders = [
  for (String key in [
    basicLightKey,
    basicHumidityKey,
    basicTemperatureKey,
    basicPhKey
  ])
    CareField(
      id: -1,
      key: key,
      type: CareFieldType.number,
      enabled: true,
      position: 0,
    ),
];

String careFieldName(L l, CareField field) => switch (field.key) {
      basicLightKey => l.sunlight,
      basicHumidityKey => l.humidity,
      basicTemperatureKey => l.temperature,
      basicPhKey => l.ph,
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

/// Icons a care category can use.
const List<String> careFieldIcons = [
  'sprout',
  'leaf',
  'flower',
  'flower_2',
  'tree_pine',
  'sun',
  'sun_medium',
  'sunrise',
  'moon',
  'droplet',
  'droplets',
  'glass_water',
  'shower_head',
  'cloud_rain',
  'snowflake',
  'thermometer',
  'spray_can',
  'test_tube',
  'wind',
  'zap',
  'shovel',
  'layers',
  'flask_conical',
  'scissors',
  'package_open',
  'bug',
  'shield_alert',
  'skull',
  'ruler',
  'heart',
  'star',
  'tag',
];

/// The icon of a built-in category when the user has not chosen another.
String? defaultCareFieldIcon(String? key) => switch (key) {
      basicLightKey => 'sun',
      basicHumidityKey => 'spray_can',
      basicTemperatureKey => 'thermometer',
      basicPhKey => 'test_tube',
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
      _ => null,
    };

/// The icon chosen by the user, or else the default one of the category.
String careFieldIconName(CareField field) =>
    field.icon ?? defaultCareFieldIcon(field.key) ?? 'sprout';

IconData careFieldIcon(CareField field) =>
    appIcons[careFieldIconName(field)] ?? LucideIcons.sprout;
