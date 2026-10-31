import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/open_plantbook_client.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/ui/core/ui/create_care_field_dialog.dart';

void main() {
  group('care field database', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('creates the built-in fields and the health event types', () async {
      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      expect(fields.map((f) => f.key),
          AppDatabase.builtInCareFields.map((f) => f.$1));
      expect(fields.every((f) => f.enabled), isTrue);

      List<String> types =
          (await db.select(db.eventTypes).get()).map((t) => t.name).toList();
      expect(types, containsAll(['pest', 'treatment']));
    });

    test('saves values by key, replaces and removes them', () async {
      int species = await db.into(db.species).insert(SpeciesCompanion.insert(
            scientificName: 'Monstera deliciosa',
            species: 'Monstera deliciosa',
          ));
      SpeciesCareValueRepository values = SpeciesCareValueRepository(db: db);
      await values.saveByKeys(species, {
        'light_lux': const CareValue(value: 2500, maxValue: 60000),
        'toxicity': const CareValue(text: 'Toxic for cats', estimated: true),
      });

      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      int lux = fields.firstWhere((f) => f.key == 'light_lux').id;
      int toxicity = fields.firstWhere((f) => f.key == 'toxicity').id;
      Map<int, CareValue> saved =
          (await values.getBySpecies(species)).getOrThrow();
      expect(saved[lux]!.maxValue, 60000);
      expect(saved[toxicity]!.estimated, isTrue);

      await values.save(species, toxicity, const CareValue(text: 'Safe'));
      await values.save(species, lux, const CareValue());
      saved = (await values.getBySpecies(species)).getOrThrow();
      expect(saved.containsKey(lux), isFalse);
      expect(saved[toxicity]!.text, 'Safe');
      expect(saved[toxicity]!.estimated, isFalse);
    });

    test('changes the icon of a built-in field and restores it', () async {
      CareFieldRepository repository = CareFieldRepository(db: db);
      CareField lux = (await repository.getAll())
          .getOrThrow()
          .firstWhere((f) => f.key == 'light_lux');
      expect(careFieldIconName(lux), 'sun_medium');

      await repository.setIcon(lux.id, 'star');
      lux = (await repository.get(lux.id)).getOrThrow();
      expect(careFieldIconName(lux), 'star');

      await repository.setIcon(lux.id, null);
      lux = (await repository.get(lux.id)).getOrThrow();
      expect(careFieldIconName(lux), 'sun_medium');
    });

    test('saves the order of the fields', () async {
      CareFieldRepository repository = CareFieldRepository(db: db);
      List<int> ids =
          (await repository.getAll()).getOrThrow().map((f) => f.id).toList();
      List<int> reversed = ids.reversed.toList();
      await repository.reorder(reversed);
      expect(
          (await repository.getAll()).getOrThrow().map((f) => f.id), reversed);
    });

    test('reads the values of a species by key', () async {
      int species = await db.into(db.species).insert(SpeciesCompanion.insert(
            scientificName: 'Echeveria elegans',
            species: 'Echeveria elegans',
          ));
      SpeciesCareValueRepository values = SpeciesCareValueRepository(db: db);
      await values.saveByKeys(species, {
        'watering_summer': const CareValue(value: 10),
        'substrate': const CareValue(text: 'Cactus mix'),
      });
      Map<String, CareValue> byKey =
          (await values.getBySpeciesKeyed(species)).getOrThrow();
      expect(byKey.keys.toSet(), {'watering_summer', 'substrate'});
      expect(byKey['watering_summer']!.value, 10);
    });

    test('adds a custom field after the built-in ones', () async {
      CareFieldRepository repository = CareFieldRepository(db: db);
      await repository.insertCustom(CareFieldsCompanion(
        name: const Value('Pot size'),
        type: const Value(CareFieldType.number),
        unit: const Value('cm'),
      ));
      List<CareField> fields = (await repository.getAll()).getOrThrow();
      expect(fields.last.name, 'Pot size');
      expect(fields.last.key, isNull);
    });
  });

  test('upgrading a version 1 database adds the care fields', () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1'); // creates the schema
      // Turn it back into a version 1 database
      await db.customStatement('DROP TABLE species_care_values');
      await db.customStatement('DROP TABLE care_fields');
      await db.customStatement(
          "DELETE FROM event_types WHERE name IN ('pest', 'treatment')");
      await db.customStatement('ALTER TABLE species DROP COLUMN description');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 1');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      expect(fields.length, AppDatabase.builtInCareFields.length);
      List<String> types =
          (await db.select(db.eventTypes).get()).map((t) => t.name).toList();
      expect(types, containsAll(['watering', 'pest', 'treatment']));
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('upgrading a version 2 database adds the category icons', () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db.customStatement('ALTER TABLE care_fields DROP COLUMN icon');
      await db.customStatement('ALTER TABLE species DROP COLUMN description');
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 2');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      CareFieldRepository repository = CareFieldRepository(db: db);
      await repository.insertCustom(const CareFieldDraft(
        name: 'Pot size',
        type: CareFieldType.number,
        icon: 'ruler',
        unit: ' cm ',
      ).toCompanion());
      CareField custom = (await repository.getAll()).getOrThrow().last;
      expect(custom.icon, 'ruler');
      expect(custom.unit, 'cm');
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('upgrading a version 4 database puts the basic care first', () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db
          .customStatement("DELETE FROM care_fields WHERE key LIKE 'basic_%'");
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 4');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      expect(fields.take(4).map((f) => f.key), [
        basicLightKey,
        basicHumidityKey,
        basicTemperatureKey,
        basicPhKey,
      ]);
      expect(fields[4].key, 'light_lux');
      expect(careFieldIconName(fields[0]), 'sun');
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('upgrading a version 5 database adds the suggestion event types',
      () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db.customStatement("DELETE FROM event_types WHERE name IN "
          "('repotting', 'inspection', 'misting', 'protect', 'move outdoors')");
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 5');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      List<String> types =
          (await db.select(db.eventTypes).get()).map((t) => t.name).toList();
      expect(
          types,
          containsAll([
            'watering',
            'pest',
            'repotting',
            'inspection',
            'misting',
            'protect',
            'move outdoors'
          ]));
      expect(types.where((t) => t == 'pest').length, 1);
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('upgrading a version 6 database adds the schedule categories last',
      () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db.customStatement("DELETE FROM care_fields WHERE key IN "
          "('misting_every', 'fertilizer_every', 'pruning_month', "
          "'repotting_years', 'repotting_month')");
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 6');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      expect(fields.length, AppDatabase.builtInCareFields.length);
      expect(fields.reversed.take(5).map((f) => f.key).toList().reversed,
          AppDatabase.scheduleCareFields.take(5));
      expect(fields.firstWhere((f) => f.key == 'pruning_month').unit, 'month');
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test(
      'upgrading a version 7 database adds the value source and the month '
      'categories', () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement("DELETE FROM care_fields WHERE key IN "
          "('flowering_months', 'dormancy_months')");
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 7');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      List<CareField> fields =
          (await CareFieldRepository(db: db).getAll()).getOrThrow();
      expect(fields.length, AppDatabase.builtInCareFields.length);
      expect(fields.reversed.take(2).map((f) => f.key).toList(),
          ['dormancy_months', 'flowering_months']);
      int species = await db.into(db.species).insert(SpeciesCompanion.insert(
            scientificName: 'Opuntia ficus-indica',
            species: 'Opuntia ficus-indica',
          ));
      SpeciesCareValueRepository values = SpeciesCareValueRepository(db: db);
      await values.saveByKeys(species, {
        'dormancy_months':
            const CareValue(value: 11, maxValue: 2, source: 'group:cacti'),
      });
      CareValue saved = (await values.getBySpeciesKeyed(species))
          .getOrThrow()['dormancy_months']!;
      expect(saved.source, 'group:cacti');
      expect(saved.maxValue, 2);
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('CareFieldDraft keeps options only for list categories', () {
    CareFieldsCompanion choice = const CareFieldDraft(
      name: 'Light exposure',
      type: CareFieldType.choice,
      icon: 'sun',
      options: [' North', 'South ', '', 'East|West'],
    ).toCompanion();
    expect(choice.options.value, 'North|South|East/West');
    CareFieldsCompanion text = const CareFieldDraft(
      name: 'Origin',
      type: CareFieldType.text,
      icon: 'leaf',
      options: ['ignored'],
    ).toCompanion();
    expect(text.options.value, isNull);
  });

  test('OpenPlantbookClient.toExtraCare keeps the measured ranges', () {
    Map<String, CareValue> extra = OpenPlantbookClient.toExtraCare({
      'min_light_lux': 2500,
      'max_light_lux': 60000,
      'min_soil_moist': 15,
      'max_soil_moist': 60,
      'min_soil_ec': 350,
      'max_soil_ec': 2000,
    });
    expect(extra['light_lux']!.value, 2500);
    expect(extra['soil_moisture']!.maxValue, 60);
    expect(extra['conductivity']!.value, 350);
    expect(extra.containsKey('env_humidity'), isFalse);
  });

  test('AiCareEstimator.parseExtraCare marks values as estimated', () {
    Map<String, CareValue> extra = AiCareEstimator.parseExtraCare(
        '{"light": 6, "watering_summer": 7, "watering_winter": "14", '
        '"toxicity": "Toxic for cats", "diseases": null, "substrate": " "}');
    expect(extra['watering_summer']!.value, 7);
    expect(extra['watering_winter']!.value, 14);
    expect(extra['toxicity']!.text, 'Toxic for cats');
    expect(extra['toxicity']!.estimated, isTrue);
    expect(extra.containsKey('diseases'), isFalse);
    expect(extra.containsKey('substrate'), isFalse);
  });

  test('AiCareEstimator.parseExtraCare drops schedule values out of range', () {
    Map<String, CareValue> extra = AiCareEstimator.parseExtraCare(
        '{"pruning_month": 4.2, "repotting_month": 13, "repotting_years": 2, '
        '"fertilizer_every": 0, "misting_every": 3}');
    expect(extra['pruning_month']!.value, 4);
    expect(extra.containsKey('repotting_month'), isFalse);
    expect(extra['repotting_years']!.value, 2);
    expect(extra.containsKey('fertilizer_every'), isFalse);
    expect(extra['misting_every']!.estimated, isTrue);
    Map<String, CareValue> months = AiCareEstimator.parseExtraCare(
        '{"flowering_from": 4, "flowering_to": 6, "dormancy_from": 11, '
        '"dormancy_to": null}');
    expect(months['flowering_months']!.value, 4);
    expect(months['flowering_months']!.maxValue, 6);
    expect(months.containsKey('dormancy_months'), isFalse);
  });
}
