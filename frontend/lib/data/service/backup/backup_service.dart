import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

/// What a restored backup brought.
class BackupSummary {
  final int plants;
  final int images;
  final DateTime? createdAt;

  const BackupSummary(this.plants, this.images, this.createdAt);
}

/// Saves everything in a single zip file and brings it back: the database
/// (plants, species, care, events, reminders, groups and settings) and the
/// photos. Keys, passwords and tokens are left out of the file.
class BackupService {
  static const String _app = 'plant-diary';
  static const int _format = 1;
  static const String _databaseName = 'plant_diary.sqlite';
  static const String _manifestName = 'backup.json';
  static const String _imagesFolder = 'images/';

  /// Settings that are not saved in a backup, and that a restore keeps.
  static final List<String> secretSettings = [
    UserSettingsKeys.floraCodexKey,
    UserSettingsKeys.plantNetKey,
    UserSettingsKeys.plantbookClientId,
    UserSettingsKeys.plantbookClientSecret,
    UserSettingsKeys.claudeKey,
    UserSettingsKeys.geminiKey,
    UserSettingsKeys.githubModelsToken,
    UserSettingsKeys.rainPointEmail,
    UserSettingsKeys.rainPointPassword,
    UserSettingsKeys.rainPointToken,
    UserSettingsKeys.rainPointTokenExpires,
  ].map((k) => k.key).toList();

  final AppDatabase _db;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<Directory> Function() _documentsDirectory;

  BackupService({
    required AppDatabase db,
    Future<Directory> Function()? temporaryDirectory,
    Future<Directory> Function()? documentsDirectory,
  })  : _db = db,
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
        _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  static String _quote(String path) => "'${path.replaceAll("'", "''")}'";

  static String _baseName(String path) =>
      path.split(RegExp(r'[/\\]')).where((p) => p.isNotEmpty).last;

  /// The default name of a backup made today.
  static String fileName(DateTime now) =>
      'plant-diary-${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}.zip';

  /// The backup as the bytes of a zip file.
  Future<Result<Uint8List>> create() async {
    try {
      Directory temp = await _temporaryDirectory();
      File copy = File('${temp.path}/backup-${_stamp()}.sqlite');
      if (await copy.exists()) await copy.delete();
      // A consistent copy of the database, even while it is in use
      await _db.customStatement('VACUUM INTO ${_quote(copy.path)}');
      await _removeSecrets(copy);

      Archive archive = Archive();
      archive
          .addFile(ArchiveFile.bytes(_databaseName, await copy.readAsBytes()));
      await copy.delete();

      int images = 0;
      Set<String> added = {};
      for (Image image in await _db.select(_db.images).get()) {
        String? path = image.imagePath;
        if (path == null) continue;
        File file = File(path);
        String name = _baseName(path);
        if (!await file.exists() || !added.add(name)) continue;
        archive.addFile(
            ArchiveFile.bytes('$_imagesFolder$name', await file.readAsBytes()));
        images++;
      }

      archive.addFile(ArchiveFile.bytes(
          _manifestName,
          utf8.encode(json.encode({
            'app': _app,
            'format': _format,
            'schema': _db.schemaVersion,
            'createdAt': DateTime.now().toIso8601String(),
            'images': images,
          }))));
      return Success(ZipEncoder().encodeBytes(archive));
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  String _stamp() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _removeSecrets(File database) async {
    AppDatabase copy = AppDatabase.forTesting(NativeDatabase(database));
    try {
      await copy.customStatement(
          'DELETE FROM user_settings WHERE key IN '
          '(${secretSettings.map((_) => '?').join(', ')})',
          secretSettings);
      // Leaves no trace of the deleted values in the file
      await copy.customStatement('VACUUM');
    } finally {
      await copy.close();
    }
  }

  /// Replaces the data of the app with the one of a backup. The settings
  /// that the backup does not have, such as keys, are kept.
  Future<Result<BackupSummary>> restore(Uint8List zip) async {
    File? database;
    try {
      Archive archive = ZipDecoder().decodeBytes(zip);
      ArchiveFile? manifestFile = archive.findFile(_manifestName);
      ArchiveFile? databaseFile = archive.findFile(_databaseName);
      if (manifestFile == null || databaseFile == null) {
        return Failure(const BackupException('not a backup of the app'));
      }
      Map<String, dynamic> manifest =
          json.decode(utf8.decode(manifestFile.content));
      if (manifest['app'] != _app) {
        return Failure(const BackupException('not a backup of the app'));
      }
      int schema = (manifest['schema'] as num?)?.toInt() ?? 0;
      if (schema > _db.schemaVersion) {
        return Failure(const BackupException(
            'made by a newer version of the app: update it first'));
      }

      Directory temp = await _temporaryDirectory();
      database = File('${temp.path}/restore-${_stamp()}.sqlite');
      await database.writeAsBytes(databaseFile.content, flush: true);
      // Opening it brings an older backup up to the current tables
      AppDatabase upgraded = AppDatabase.forTesting(NativeDatabase(database));
      await upgraded.customSelect('SELECT 1').get();
      await upgraded.close();

      await _copyTables(database);
      int images = await _restoreImages(archive);
      int plants = await _db.managers.plants.count();
      return Success(BackupSummary(
          plants, images, DateTime.tryParse('${manifest['createdAt'] ?? ''}')));
    } catch (e) {
      return Failure(Exception(e.toString()));
    } finally {
      if (database != null && await database.exists()) {
        await database.delete();
      }
    }
  }

  Future<List<String>> _columns(String schema, String table) async =>
      (await _db.customSelect('PRAGMA $schema.table_info("$table")').get())
          .map((row) => row.read<String>('name'))
          .toList();

  Future<void> _copyTables(File backup) async {
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    await _db.customStatement('ATTACH DATABASE ${_quote(backup.path)} AS bk');
    try {
      await _db.transaction(() async {
        for (TableInfo table in _db.allTables) {
          String name = table.actualTableName;
          List<String> mine = await _columns('main', name);
          List<String> theirs = await _columns('bk', name);
          List<String> common = mine.where(theirs.contains).toList();
          if (common.isEmpty) continue;
          String columns = common.map((c) => '"$c"').join(', ');
          if (name == _db.userSettings.actualTableName) {
            // Settings the backup does not have are kept
            await _db.customStatement(
                'INSERT OR REPLACE INTO main."$name" ($columns) '
                'SELECT $columns FROM bk."$name"');
            continue;
          }
          await _db.customStatement('DELETE FROM main."$name"');
          await _db.customStatement('INSERT INTO main."$name" ($columns) '
              'SELECT $columns FROM bk."$name"');
        }
      });
    } finally {
      await _db.customStatement('DETACH DATABASE bk');
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
  }

  /// Puts the photos of the backup in the folder of the app, and points the
  /// images to them.
  Future<int> _restoreImages(Archive archive) async {
    Directory folder =
        Directory('${(await _documentsDirectory()).path}/images');
    await folder.create(recursive: true);
    Set<String> restored = {};
    for (ArchiveFile file in archive.files) {
      if (!file.isFile || !file.name.startsWith(_imagesFolder)) continue;
      String name = _baseName(file.name);
      await File('${folder.path}/$name').writeAsBytes(file.content);
      restored.add(name);
    }
    for (Image image in await _db.select(_db.images).get()) {
      String? path = image.imagePath;
      if (path == null) continue;
      String name = _baseName(path);
      if (!restored.contains(name)) continue;
      await (_db.update(_db.images)..where((i) => i.id.equals(image.id)))
          .write(ImagesCompanion(imagePath: Value('${folder.path}/$name')));
    }
    return restored.length;
  }
}

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}
