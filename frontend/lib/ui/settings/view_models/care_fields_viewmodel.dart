import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/ui/core/ui/create_care_field_dialog.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

class CareFieldsViewModel extends ChangeNotifier {
  CareFieldsViewModel({
    required CareFieldRepository careFieldRepository,
    required StreamController<StreamCode> streamController,
  })  : _careFieldRepository = careFieldRepository,
        _streamController = streamController {
    load = Command.createAsyncNoParam(() async {
      Result<List<CareField>> fields = await _careFieldRepository.getAll();
      if (fields.isError()) throw fields.exceptionOrNull()!;
      _fields = fields.getOrThrow();
      notifyListeners();
    }, initialValue: null);
  }

  final CareFieldRepository _careFieldRepository;
  final StreamController<StreamCode> _streamController;

  late final Command<void, void> load;
  List<CareField> _fields = [];

  List<CareField> get fields => _fields;

  Future<Result<void>> _reload(Result<dynamic> result) async {
    if (result.isError()) {
      return Failure(result.exceptionOrNull()!);
    }
    // The species and plant pages show the enabled fields
    _streamController.add(StreamCode.editSpecies);
    await load.executeWithFuture();
    return Success("ok");
  }

  Future<Result<void>> setEnabled(CareField field, bool enabled) async =>
      _reload(await _careFieldRepository.setEnabled(field.id, enabled));

  Future<Result<void>> add(CareFieldDraft draft) async =>
      _reload(await _careFieldRepository.insertCustom(draft.toCompanion()));

  Future<Result<void>> delete(CareField field) async =>
      _reload(await _careFieldRepository.delete(field.id));
}
