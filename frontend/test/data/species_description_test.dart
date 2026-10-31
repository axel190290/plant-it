import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/service/care/species_description_service.dart';
import 'package:plant_it/data/service/search/gbif_searcher.dart';
import 'package:plant_it/database/database.dart';

void main() {
  test('GbifSearcher.cleanSummary removes the HTML of Wikipedia', () {
    expect(
        GbifSearcher.cleanSummary(
            '<b>Zamioculcas zamiifolia</b> es una planta&nbsp;de <i>Araceae</i>.\n'),
        'Zamioculcas zamiifolia es una planta de Araceae.');
    expect(GbifSearcher.cleanSummary('  '), isNull);
    String long =
        List.filled(100, 'Una frase larga sobre la planta.').join(' ');
    String cut = GbifSearcher.cleanSummary(long)!;
    expect(cut.length, lessThanOrEqualTo(600));
    expect(cut.endsWith('.'), isTrue);
  });

  test('SpeciesDescriptionService.compose prefers the summary', () {
    expect(
      SpeciesDescriptionService.compose('Summary.', 'AI description.',
          '• Toxic for pets\n- Yellow leaves mean too much water\n'),
      'Summary.\n\n• Toxic for pets\n• Yellow leaves mean too much water',
    );
    expect(SpeciesDescriptionService.compose(null, 'AI description.', null),
        'AI description.');
    expect(SpeciesDescriptionService.compose(null, null, ' '), isNull);
  });

  test('upgrading a version 3 database adds the species description', () async {
    Directory dir = await Directory.systemTemp.createTemp('plant_it_test');
    File file = File('${dir.path}/db.sqlite');
    try {
      AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
      await db.customStatement('SELECT 1');
      await db.customStatement('ALTER TABLE species DROP COLUMN description');
      await db.customStatement(
          'ALTER TABLE species_care_values DROP COLUMN source');
      await db.customStatement('DROP TABLE sensor_readings');
      await db.customStatement('DROP TABLE plant_collections');
      await db.customStatement('DROP TABLE collections');
      await db.customStatement('PRAGMA user_version = 3');
      await db.close();

      db = AppDatabase.forTesting(NativeDatabase(file));
      int id = await db.into(db.species).insert(SpeciesCompanion.insert(
            scientificName: 'Zamioculcas zamiifolia',
            species: 'Zamioculcas zamiifolia',
            description: const Value('Planta ZZ'),
          ));
      Specy species = await (db.select(db.species)
            ..where((s) => s.id.equals(id)))
          .getSingle();
      expect(species.description, 'Planta ZZ');
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
