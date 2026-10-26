import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/repository/species_repository.dart';
import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/care/suggestion_care_filler.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_sources.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/ui/core/ui/create_care_field_dialog.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// Edits the whole care of a species: the basic care (light, humidity,
/// temperature, pH) and the values of the enabled care categories.
class EditCareValuesViewModel extends ChangeNotifier {
  EditCareValuesViewModel({
    required CareFieldRepository careFieldRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required SpeciesCareRepository speciesCareRepository,
    required SpeciesRepository speciesRepository,
    required SuggestionCareFiller suggestionCareFiller,
    required StreamController<StreamCode> streamController,
  })  : _careFieldRepository = careFieldRepository,
        _suggestionCareFiller = suggestionCareFiller,
        _speciesCareValueRepository = speciesCareValueRepository,
        _speciesCareRepository = speciesCareRepository,
        _speciesRepository = speciesRepository,
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
  final SpeciesCareRepository _speciesCareRepository;
  final SpeciesRepository _speciesRepository;
  final SuggestionCareFiller _suggestionCareFiller;
  final StreamController<StreamCode> _streamController;

  late final Command<int, void> load;
  late final Command<void, bool> save;

  late int _speciesId;
  bool _hasCareRow = false;
  late SpeciesCareCompanion _originalCare;
  late SpeciesCareCompanion _care;
  List<CareField> _fields = [];
  Map<String, CareField> _basicFields = {};
  Map<int, CareValue> _original = {};
  final Map<int, CareValue> _values = {};
  // Values filled in by the AI and not saved yet
  final Map<int, CareValue> _aiValues = {};
  SpeciesCareCompanion? _aiCare;
  AiProvider _aiProvider = AiProvider.none;
  int _generation = 0;
  bool _filling = false;

  /// The enabled categories, in display order.
  List<CareField> get fields => _fields;
  SpeciesCareCompanion get care => _care;

  /// The basic care category of [key], if loaded.
  CareField? basicField(String key) => _basicFields[key];

  CareValue valueOf(int fieldId) => _values[fieldId] ?? const CareValue();

  /// Whether an AI provider is configured.
  bool get aiAvailable => _aiProvider != AiProvider.none;

  /// Whether the AI is filling in the values.
  bool get filling => _filling;

  /// Changes when the values are replaced, so the editors show them again.
  int get generation => _generation;

  void setValue(int fieldId, CareValue value) {
    _values[fieldId] = value;
  }

  void setCare(SpeciesCareCompanion care) {
    _care = care;
    notifyListeners();
  }

  Future<Result<void>> _load(int speciesId) async {
    _speciesId = speciesId;
    Result<SpeciesCareData> care = await _speciesCareRepository.get(speciesId);
    _hasCareRow = care.isSuccess();
    _originalCare = care.isSuccess()
        ? care.getOrThrow().toCompanion(true)
        : SpeciesCareCompanion(species: Value(speciesId));
    _care = _originalCare;

    Result<void> fields = await _loadFields();
    if (fields.isError()) {
      return fields;
    }
    Result<Map<int, CareValue>> values =
        await _speciesCareValueRepository.getBySpecies(speciesId);
    if (values.isError()) {
      return Failure(values.exceptionOrNull()!);
    }
    _original = values.getOrThrow();
    _values
      ..clear()
      ..addAll(_original);
    _aiProvider = await _suggestionCareFiller.configuredProvider();
    notifyListeners();
    return Success("ok");
  }

  Future<Result<void>> _loadFields() async {
    Result<List<CareField>> fields = await _careFieldRepository.getAll();
    if (fields.isError()) {
      return Failure(fields.exceptionOrNull()!);
    }
    // The basic care is edited with its own controls
    _fields = fields
        .getOrThrow()
        .where((f) => f.enabled && !isBasicCareField(f))
        .toList();
    _basicFields = {
      for (CareField f in fields.getOrThrow())
        if (isBasicCareField(f)) f.key!: f
    };
    return Success("ok");
  }

  /// Creates a care category, keeping the values being edited.
  Future<Result<void>> addField(CareFieldDraft draft) async {
    Result<int> id =
        await _careFieldRepository.insertCustom(draft.toCompanion());
    if (id.isError()) {
      return Failure(id.exceptionOrNull()!);
    }
    Result<void> fields = await _loadFields();
    if (fields.isError()) {
      return fields;
    }
    // Other pages show the new category too
    _streamController.add(StreamCode.editSpecies);
    notifyListeners();
    return Success("ok");
  }

  /// Fills with the AI the empty categories the reminder suggestions read.
  /// Returns how many values were filled in; nothing is saved yet.
  Future<Result<int>> fillWithAi() async {
    _filling = true;
    notifyListeners();
    try {
      return await _fillWithAi();
    } finally {
      _filling = false;
      notifyListeners();
    }
  }

  Future<Result<int>> _fillWithAi() async {
    Result<Specy> species = await _speciesRepository.get(_speciesId);
    if (species.isError()) {
      return Failure(species.exceptionOrNull()!);
    }
    Result<CareData> estimate =
        await _suggestionCareFiller.estimate(species.getOrThrow());
    if (estimate.isError()) {
      return Failure(estimate.exceptionOrNull()!);
    }
    _aiProvider = await _suggestionCareFiller.configuredProvider();
    int filled = 0;
    for (CareField field in _fields.where(isSuggestionCareField)) {
      CareValue? value = estimate.getOrThrow().extra[field.key];
      if (value != null && valueOf(field.id).isEmpty) {
        _values[field.id] = value;
        _aiValues[field.id] = value;
        filled++;
      }
    }

    SpeciesCareCompanion ai = estimate.getOrThrow().care;
    SpeciesCareCompanion care = _care;
    if (_basicFields[basicHumidityKey]?.enabled != false &&
        care.humidity.value == null &&
        ai.humidity.value != null) {
      care = care.copyWith(humidity: ai.humidity);
      filled++;
    }
    if (_basicFields[basicTemperatureKey]?.enabled != false &&
        care.tempMin.value == null &&
        care.tempMax.value == null &&
        ai.tempMin.value != null &&
        ai.tempMax.value != null) {
      care = care.copyWith(tempMin: ai.tempMin, tempMax: ai.tempMax);
      filled++;
    }
    _care = care;
    _aiCare = ai;
    _generation++;
    notifyListeners();
    return Success(filled);
  }

  bool _same(CareValue a, CareValue b) =>
      a.value == b.value && a.maxValue == b.maxValue && a.text == b.text;

  Future<Result<void>> _save() async {
    Result<void> care = await _saveCare();
    if (care.isError()) {
      return care;
    }
    for (CareField field in _fields) {
      CareValue original = _original[field.id] ?? const CareValue();
      CareValue value = valueOf(field.id);
      if (_same(original, value)) {
        continue;
      }
      // A value written by the user is no longer an AI estimate
      CareValue? ai = _aiValues[field.id];
      bool estimated = ai != null && _same(ai, value);
      Result<void> saved = await _speciesCareValueRepository.save(
          _speciesId, field.id, value.copyWith(estimated: estimated));
      if (saved.isError()) {
        return saved;
      }
    }
    return Success("ok");
  }

  Future<Result<void>> _saveCare() async {
    List<String> changed = CareSources.groupFields([
      if (_care.light.value != _originalCare.light.value) 'light',
      if (_care.humidity.value != _originalCare.humidity.value) 'humidity',
      if (_care.tempMin.value != _originalCare.tempMin.value) 'tempMin',
      if (_care.tempMax.value != _originalCare.tempMax.value) 'tempMax',
      if (_care.phMin.value != _originalCare.phMin.value) 'phMin',
      if (_care.phMax.value != _originalCare.phMax.value) 'phMax',
    ]);
    if (changed.isEmpty) {
      return Success("ok");
    }
    Result<Object> saved = _hasCareRow
        ? await _speciesCareRepository.update(_care)
        : await _speciesCareRepository.insert(_care);
    if (saved.isError()) {
      return Failure(saved.exceptionOrNull()!);
    }
    // Values filled in by the AI and kept as they were stay estimates
    SpeciesCareCompanion? ai = _aiCare;
    List<String> byAi = ai == null
        ? []
        : CareSources.groupFields([
            if (_care.humidity.value != null &&
                _care.humidity.value == ai.humidity.value)
              'humidity',
            if (_care.tempMin.value != null &&
                _care.tempMin.value == ai.tempMin.value &&
                _care.tempMax.value == ai.tempMax.value)
              'tempMin',
          ]);
    return _updateAiEstimate(
        changed.where((f) => !byAi.contains(f)).toList(), byAi);
  }

  /// Values set by the user are no longer AI estimates; [byAi] are.
  Future<Result<void>> _updateAiEstimate(
      List<String> fields, List<String> byAi) async {
    Result<Specy> species = await _speciesRepository.get(_speciesId);
    if (species.isError()) {
      return Failure(species.exceptionOrNull()!);
    }
    CareSources? sources =
        CareSources.decode(species.getOrThrow().bibliography);
    if (byAi.isEmpty &&
        (sources == null || !sources.aiFields.any(fields.contains))) {
      return Success("ok");
    }
    sources ??= const CareSources();
    List<String> aiFields = {
      ...sources.aiFields.where((f) => !fields.contains(f)),
      ...byAi,
    }.toList();
    CareSources updated = CareSources(
      species: sources.species,
      care: sources.care,
      aiProvider: byAi.isEmpty ? sources.aiProvider : _aiProvider.key,
      aiFields: aiFields,
    );
    Result<bool> saved = await _speciesRepository.update(species
        .getOrThrow()
        .toCompanion(true)
        .copyWith(bibliography: Value(updated.encode())));
    if (saved.isError()) {
      return Failure(saved.exceptionOrNull()!);
    }
    return Success("ok");
  }
}
