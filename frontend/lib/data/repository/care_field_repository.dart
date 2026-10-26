import 'package:drift/drift.dart';
import 'package:plant_it/data/repository/crud_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:result_dart/result_dart.dart';

class CareFieldRepository extends CRUDRepository<CareField> {
  CareFieldRepository({required super.db});

  @override
  TableInfo<Table, CareField> get table => db.careFields;

  /// Every field in display order.
  @override
  Future<Result<List<CareField>>> getAll() async {
    try {
      List<CareField> fields = await (db.select(db.careFields)
            ..orderBy([
              (f) => OrderingTerm(expression: f.position),
              (f) => OrderingTerm(expression: f.id),
            ]))
          .get();
      return Success(fields);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<void>> setEnabled(int id, bool enabled) async {
    try {
      await (db.update(db.careFields)..where((f) => f.id.equals(id)))
          .write(CareFieldsCompanion(enabled: Value(enabled)));
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Sets the icon of a field; null goes back to its default icon.
  Future<Result<void>> setIcon(int id, String? icon) async {
    try {
      await (db.update(db.careFields)..where((f) => f.id.equals(id)))
          .write(CareFieldsCompanion(icon: Value(icon)));
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Saves the display order, given as field ids from first to last.
  Future<Result<void>> reorder(List<int> ids) async {
    try {
      await db.transaction(() async {
        for (int i = 0; i < ids.length; i++) {
          await (db.update(db.careFields)..where((f) => f.id.equals(ids[i])))
              .write(CareFieldsCompanion(position: Value(i)));
        }
      });
      return Success("ok");
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  /// Adds a field created by the user after the existing ones.
  Future<Result<int>> insertCustom(CareFieldsCompanion field) async {
    try {
      Expression<int> maxPosition = db.careFields.position.max();
      int? last = await (db.selectOnly(db.careFields)
            ..addColumns([maxPosition]))
          .map((row) => row.read(maxPosition))
          .getSingleOrNull();
      int id = await db.into(db.careFields).insert(field.copyWith(
          key: const Value(null), position: Value((last ?? 0) + 1)));
      return Success(id);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
