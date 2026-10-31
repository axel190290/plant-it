import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/data/service/backup/backup_service.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// Saves all the data of the app to a file, and brings it back from one.
class BackupScreen extends StatefulWidget {
  final BackupService backupService;
  final StreamController<StreamCode> streamController;

  const BackupScreen({
    super.key,
    required this.backupService,
    required this.streamController,
  });

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _create() async {
    L l = L.of(context);
    setState(() => _busy = true);
    try {
      Result<Uint8List> backup = await widget.backupService.create();
      if (!mounted) return;
      if (backup.isError()) {
        _showMessage(l.errorWithMessage(backup.exceptionOrNull().toString()));
        return;
      }
      String? saved = await FilePicker.saveFile(
        dialogTitle: l.createBackup,
        fileName: BackupService.fileName(DateTime.now()),
        bytes: backup.getOrThrow(),
      );
      if (saved != null && mounted) _showMessage(l.backupSaved);
    } catch (e) {
      if (mounted) _showMessage(l.errorWithMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    L l = L.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restoreBackup),
        content: Text(l.restoreBackupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.restore),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    FilePickerResult? picked = await FilePicker.pickFiles(withData: true);
    Uint8List? bytes = picked?.files.single.bytes;
    if (bytes == null || !mounted) return;

    setState(() => _busy = true);
    Result<BackupSummary> result = await widget.backupService.restore(bytes);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isError()) {
      _showMessage(l.errorWithMessage(result.exceptionOrNull().toString()));
      return;
    }
    // Every screen loads its data again
    for (StreamCode code in [
      StreamCode.insertPlant,
      StreamCode.editSpecies,
      StreamCode.insertEvent,
      StreamCode.insertReminder,
      StreamCode.editWeather,
    ]) {
      widget.streamController.add(code);
    }
    BackupSummary summary = result.getOrThrow();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.restoreBackup),
        content: Text(l.backupRestored(summary.plants, summary.images)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.backup)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            ListTile(
              leading: const Icon(LucideIcons.hard_drive_download),
              title: Text(l.createBackup),
              subtitle: Text(l.createBackupHint),
              enabled: !_busy,
              onTap: _create,
            ),
            ListTile(
              leading: const Icon(LucideIcons.archive_restore),
              title: Text(l.restoreBackup),
              subtitle: Text(l.restoreBackupHint),
              enabled: !_busy,
              onTap: _restore,
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
