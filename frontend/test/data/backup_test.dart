import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/service/backup/backup_service.dart';
import 'package:plant_it/database/database.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('plant_it_backup');
  });

  tearDown(() => dir.delete(recursive: true));

  Future<Directory> folder(String name) async =>
      Directory('${dir.path}/$name').create(recursive: true);

  test(
      'a backup brings back plants, groups, photos and settings, '
      'without the keys', () async {
    // The phone the backup is made on
    AppDatabase old = AppDatabase.forTesting(NativeDatabase.memory());
    Directory oldDocs = await folder('old');
    File photo = File('${oldDocs.path}/images/abc.jpg');
    await photo.create(recursive: true);
    await photo.writeAsBytes([1, 2, 3]);
    int species = await old.into(old.species).insert(SpeciesCompanion.insert(
        scientificName: 'Aloe vera', species: 'Aloe vera'));
    int plant = await old
        .into(old.plants)
        .insert(PlantsCompanion.insert(name: 'Aloe', species: species));
    await old.into(old.images).insert(
        ImagesCompanion(imagePath: Value(photo.path), plantId: Value(plant)));
    int group =
        (await CollectionRepository(db: old).insert('Balcón')).getOrThrow();
    await CollectionRepository(db: old).setPlantsOfCollection(group, {plant});
    await old.into(old.userSettings).insert(
        UserSettingsCompanion.insert(key: 'weather_place', value: 'Madrid'));
    await old.into(old.userSettings).insert(
        UserSettingsCompanion.insert(key: 'claude_key', value: 'sk-secret'));

    Uint8List zip = (await BackupService(
      db: old,
      temporaryDirectory: () => folder('tmp-old'),
      documentsDirectory: () async => oldDocs,
    ).create())
        .getOrThrow();
    await old.close();
    expect(String.fromCharCodes(zip).contains('sk-secret'), isFalse);

    // A new phone, with its own key and a plant that the restore replaces
    AppDatabase now = AppDatabase.forTesting(NativeDatabase.memory());
    Directory newDocs = await folder('new');
    await now
        .into(now.userSettings)
        .insert(UserSettingsCompanion.insert(key: 'gemini_key', value: 'mine'));
    int other = await now.into(now.species).insert(
        SpeciesCompanion.insert(scientificName: 'Rosa', species: 'Rosa'));
    await now
        .into(now.plants)
        .insert(PlantsCompanion.insert(name: 'Rosal', species: other));

    BackupSummary summary = (await BackupService(
      db: now,
      temporaryDirectory: () => folder('tmp-new'),
      documentsDirectory: () async => newDocs,
    ).restore(zip))
        .getOrThrow();
    expect(summary.plants, 1);
    expect(summary.images, 1);

    List<Plant> plants = await now.select(now.plants).get();
    expect(plants.single.name, 'Aloe');
    expect(
        (await CollectionRepository(db: now).getPlantsByCollection())
            .getOrThrow(),
        {
          group: {plant}
        });
    Image image = (await now.select(now.images).get()).single;
    expect(image.imagePath, '${newDocs.path}/images/abc.jpg');
    expect(await File(image.imagePath!).readAsBytes(), [1, 2, 3]);
    Map<String, String> settings = {
      for (UserSetting s in await now.select(now.userSettings).get())
        s.key: s.value
    };
    expect(settings['weather_place'], 'Madrid');
    expect(settings['gemini_key'], 'mine');
    expect(settings.containsKey('claude_key'), isFalse);

    // New rows do not collide with the restored ones
    int next = await now
        .into(now.plants)
        .insert(PlantsCompanion.insert(name: 'Nueva', species: species));
    expect(next, greaterThan(plant));
    await now.close();
  });

  test('refuses a file that is not a backup', () async {
    AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
    BackupService service =
        BackupService(db: db, temporaryDirectory: () => folder('tmp'));
    expect((await service.restore(Uint8List.fromList([1, 2, 3]))).isError(),
        isTrue);
    await db.close();
  });
}
