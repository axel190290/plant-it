import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/weather.dart';

void main() {
  late AppDatabase db;
  late CollectionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepository(db: db);
  });

  tearDown(() => db.close());

  Future<int> plant(String name) async {
    int species = await db.into(db.species).insert(SpeciesCompanion.insert(
          scientificName: name,
          species: name,
        ));
    return db
        .into(db.plants)
        .insert(PlantsCompanion.insert(name: name, species: species));
  }

  test('groups keep their order and their plants', () async {
    int balcony = (await repository.insert(' Balcony ')).getOrThrow();
    int living = (await repository.insert('Living room')).getOrThrow();
    int cactus = await plant('Cactus');
    int fern = await plant('Fern');

    await repository.setPlantsOfCollection(balcony, {cactus, fern});
    await repository.setCollectionsOfPlant(fern, {living});

    List<Collection> groups = (await repository.getAll()).getOrThrow();
    expect(groups.map((g) => g.name), ['Balcony', 'Living room']);
    Map<int, Set<int>> plants =
        (await repository.getPlantsByCollection()).getOrThrow();
    expect(plants[balcony], {cactus});
    expect(plants[living], {fern});
    expect(
        (await repository.getCollectionsOfPlant(fern)).getOrThrow(), {living});

    await repository.rename(living, 'Salón');
    await repository.delete(balcony);
    groups = (await repository.getAll()).getOrThrow();
    expect(groups.map((g) => g.name), ['Salón']);
    expect(await db.select(db.plants).get(), hasLength(2));

    // Deleting a plant takes it out of its groups
    await (db.delete(db.plants)..where((p) => p.id.equals(fern))).go();
    expect((await repository.getPlantsByCollection()).getOrThrow(), isEmpty);
  });

  test('WeatherAlert.key identifies the alert by day, kind and plants', () {
    DateTime today = DateTime(2026, 10, 30);
    WeatherAlert frost = WeatherAlert(
      type: WeatherAlertType.frost,
      plants: const ['Monstera'],
      day: DayForecast(date: DateTime(2026, 11, 2)),
    );
    expect(frost.key(today), '2026-11-02|frost|Monstera');
    WeatherAlert rain =
        const WeatherAlert(type: WeatherAlertType.rain, plants: ['A', 'B']);
    expect(rain.key(today), '2026-10-30|rain|A,B');
  });
}
