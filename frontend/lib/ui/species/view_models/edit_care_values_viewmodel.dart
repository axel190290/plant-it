import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

class EditCareValuesViewModel extends ChangeNotifier {
  EditCareValuesViewModel({
    required CareFieldRepository careFieldRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required StreamController<StreamCode> streamController,
  })  : _careFieldRepository = careFieldRepository,
        _speciesCareValueRepository = speciesCareValueRepository,
        _streamController = streamController {
    load = Command.createAsyncNoResult((int speciesId) async {
      Result<void> result = await _load(speciesId);
      if (result.isError()) throw result.exceptionOrNull()!;
    });
    save = Command.createAsyncNoParam(() async {
      Result<void> result = await _save();
      if (result.isError()) throw result.exceptionOrNull()!;
      _streamController.add(StreamCode.editSpecies);
      return true;
    }, initialValue: false);
  }

  final CareFieldRepository _careFieldRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final StreamController<StreamCode> _streamController;

  late final Command<int, void> load;
  late final Command<void, bool> save;

  late int _speciesId;
  List<CareField> _fields = [];
  Map<int, CareValue> _original = {};
  final Map<int, CareValue> _values = {};

  /// The enabled fields, in display order.
  List<CareField> get fields => _fields;

  CareValue valueOf(int fieldId) => _values[fieldId] ?? const CareValue();

  void setValue(int fieldId, CareValue value) {
    _values[fieldId] = value;
  }

  Future<Result<void>> _load(int speciesId) async {
    _speciesId = speciesId;
    Result<List<CareField>> fields = await _careFieldRepository.getAll();
    if (fields.isError()) {
      return Failure(fields.exceptionOrNull()!);
    }
    _fields = fields.getOrThrow().where((f) => f.enabled).toList();
    Result<Map<int, CareValue>> values =
        await _speciesCareValueRepository.getBySpecies(speciesId);
    if (values.isError()) {
      return Failure(values.exceptionOrNull()!);
    }
    _original = values.getOrThrow();
    _values
      ..clear()
      ..addAll(_original);
    notifyListeners();
    return Success("ok");
  }

  bool _same(CareValue a, CareValue b) =>
      a.value == b.value && a.maxValue == b.maxValue && a.text == b.text;

  Future<Result<void>> _save() async {
    for (CareField field in _fields) {
      CareValue original = _original[field.id] ?? const CareValue();
      CareValue value = valueOf(field.id);
      if (_same(original, value)) {
        continue;
      }
      // A value written by the user is no longer an AI estimate
      Result<void> saved = await _speciesCareValueRepository.save(
          _speciesId, field.id, value.copyWith(estimated: false));
      if (saved.isError()) {
        return saved;
      }
    }
    return Success("ok");
  }
}
