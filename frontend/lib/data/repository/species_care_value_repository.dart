import 'package:drift/drift.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:result_dart/result_dart.dart';

class SpeciesCareValueRepository {
  final AppDatabase db;

  SpeciesCareValueRepository({required this.db});

  /// The values of a species, by care field id.
  Future<Result<Map<int, CareValue>>> getBySpecies(int speciesId) async {
    try {
      List<SpeciesCareValue> rows = await (db.select(db.speciesCareValues)
            ..where((v) => v.species.equals(speciesId)))
          .get();
      return Success({
        for (SpeciesCareValue row in rows)
          row.field: CareValue(
            value: row.value,
            maxValue: row.maxValue,
            text: row.textValue,
            estimated: row.estimated,
          )
      });
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// The values of the built-in fields of a species, by field key.
  Future<Result<Map<String, CareValue>>> getBySpeciesKeyed(
      int speciesId) async {
    try {
      List<TypedResult> rows = await (db.select(db.speciesCareValues).join([
        innerJoin(db.careFields,
            db.careFields.id.equalsExp(db.speciesCareValues.field)),
      ])
            ..where(db.speciesCareValues.species.equals(speciesId) &
                db.careFields.key.isNotNull()))
          .get();
      return Success({
        for (TypedResult row in rows)
          row.readTable(db.careFields).key!: CareValue(
            value: row.readTable(db.speciesCareValues).value,
            maxValue: row.readTable(db.speciesCareValues).maxValue,
            text: row.readTable(db.speciesCareValues).textValue,
            estimated: row.readTable(db.speciesCareValues).estimated,
          )
      });
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Replaces the value of a field, or removes it when [value] is empty.
  Future<Result<void>> save(int speciesId, int fieldId, CareValue value) async {
    try {
      if (value.isEmpty) {
        await (db.delete(db.speciesCareValues)
              ..where(
                  (v) => v.species.equals(speciesId) & v.field.equals(fieldId)))
            .go();
      } else {
        await db.into(db.speciesCareValues).insertOnConflictUpdate(
              SpeciesCareValuesCompanion.insert(
                species: speciesId,
                field: fieldId,
                value: Value(value.value),
                maxValue: Value(value.maxValue),
                textValue: Value(value.text),
                estimated: Value(value.estimated),
              ),
            );
      }
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Saves values of built-in fields given by key, as returned by the
  /// external data sources.
  Future<Result<void>> saveByKeys(
      int speciesId, Map<String, CareValue> values) async {
    try {
      List<CareField> fields = await (db.select(db.careFields)
            ..where((f) => f.key.isIn(values.keys)))
          .get();
      for (CareField field in fields) {
        Result<void> saved =
            await save(speciesId, field.id, values[field.key]!);
        if (saved.isError()) {
          return saved;
        }
      }
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
