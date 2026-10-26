import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations_es.dart';
import 'package:plant_it/ui/core/ui/care_note.dart';

CareField _field(int id, String key, CareFieldType type,
        {String? unit, bool enabled = true}) =>
    CareField(
        id: id,
        key: key,
        type: type,
        unit: unit,
        enabled: enabled,
        position: id);

void main() {
  List<CareField> fields = [
    _field(1, 'basic_temperature', CareFieldType.range),
    _field(2, 'watering_summer', CareFieldType.number, unit: 'days'),
    _field(3, 'water_type', CareFieldType.text),
    _field(4, 'watering_method', CareFieldType.text, enabled: false),
    _field(5, 'common_pests', CareFieldType.text),
    _field(6, 'diseases', CareFieldType.text),
  ];
  Map<String, CareValue> values = {
    'watering_summer': const CareValue(value: 7),
    'water_type': const CareValue(text: 'De lluvia'),
    'watering_method': const CareValue(text: 'Por inmersión'),
    'common_pests': const CareValue(text: 'Cochinilla'),
  };

  test('careNote lists the care that matters for the event types', () {
    String? note = careNote(LEs(), ['watering', 'inspection', 'protect'],
        fields, values, const SpeciesCareData(species: 1, tempMin: 10));
    expect(
        note,
        'Riego en verano: cada 7 días\n'
        'Tipo de agua: De lluvia\n'
        'Plagas habituales: Cochinilla\n'
        'Temperatura: min 10 °C');
  });

  test('careNote is null without care for the types', () {
    expect(careNote(LEs(), ['watering'], fields, {}, null), isNull);
    expect(careNote(LEs(), ['custom type'], fields, values, null), isNull);
  });
}
