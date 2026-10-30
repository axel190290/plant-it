import 'package:drift/drift.dart';
import 'package:plant_it/database/database.dart';
import 'package:result_dart/result_dart.dart';

/// The groups of plants made by the user and the plants in each one.
class CollectionRepository {
  final AppDatabase db;

  CollectionRepository({required this.db});

  /// The groups, in the order chosen by the user.
  Future<Result<List<Collection>>> getAll() async {
    try {
      return Success(await (db.select(db.collections)
            ..orderBy([
              (c) => OrderingTerm.asc(c.position),
              (c) => OrderingTerm.asc(c.id),
            ]))
          .get());
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Creates a group after the existing ones and returns its id.
  Future<Result<int>> insert(String name) async {
    try {
      int last = await db
          .customSelect(
              'SELECT COALESCE(MAX(position), 0) AS last FROM collections')
          .map((row) => row.read<int>('last'))
          .getSingle();
      return Success(await db.into(db.collections).insert(
          CollectionsCompanion.insert(
              name: _clean(name), position: Value(last + 1))));
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<void>> rename(int id, String name) async {
    try {
      await (db.update(db.collections)..where((c) => c.id.equals(id)))
          .write(CollectionsCompanion(name: Value(_clean(name))));
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Deletes a group; its plants are kept.
  Future<Result<void>> delete(int id) async {
    try {
      await (db.delete(db.plantCollections)
            ..where((p) => p.collection.equals(id)))
          .go();
      await (db.delete(db.collections)..where((c) => c.id.equals(id))).go();
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// The ids of the plants of each group, by group id.
  Future<Result<Map<int, Set<int>>>> getPlantsByCollection() async {
    try {
      Map<int, Set<int>> result = {};
      for (PlantCollection row in await db.select(db.plantCollections).get()) {
        result.putIfAbsent(row.collection, () => {}).add(row.plant);
      }
      return Success(result);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// The ids of the groups [plantId] is in.
  Future<Result<Set<int>>> getCollectionsOfPlant(int plantId) async {
    try {
      return Success((await (db.select(db.plantCollections)
                ..where((p) => p.plant.equals(plantId)))
              .get())
          .map((row) => row.collection)
          .toSet());
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Puts [plantId] in exactly the groups [collectionIds].
  Future<Result<void>> setCollectionsOfPlant(
      int plantId, Set<int> collectionIds) async {
    try {
      await db.transaction(() async {
        await (db.delete(db.plantCollections)
              ..where((p) => p.plant.equals(plantId)))
            .go();
        for (int id in collectionIds) {
          await db.into(db.plantCollections).insert(
              PlantCollectionsCompanion.insert(plant: plantId, collection: id));
        }
      });
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Makes [plantIds] exactly the plants of the group [collectionId].
  Future<Result<void>> setPlantsOfCollection(
      int collectionId, Set<int> plantIds) async {
    try {
      await db.transaction(() async {
        await (db.delete(db.plantCollections)
              ..where((p) => p.collection.equals(collectionId)))
            .go();
        for (int id in plantIds) {
          await db.into(db.plantCollections).insert(
              PlantCollectionsCompanion.insert(
                  plant: id, collection: collectionId));
        }
      });
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  static String _clean(String name) {
    String trimmed = name.trim();
    return trimmed.length > 50 ? trimmed.substring(0, 50) : trimmed;
  }
}
