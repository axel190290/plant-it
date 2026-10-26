import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/reminder_repository.dart';
import 'package:plant_it/data/repository/species_repository.dart';
import 'package:plant_it/data/service/care/reminder_suggestion_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

class AddReminderViewModel extends ChangeNotifier {
  AddReminderViewModel({
    required ReminderRepository reminderRepository,
    required EventTypeRepository eventTypeRepository,
    required PlantRepository plantRepository,
    required SpeciesRepository speciesRepository,
    required StreamController<StreamCode> streamController,
    required ReminderSuggestionService reminderSuggestionService,
  })  : _reminderSuggestionService = reminderSuggestionService,
        _streamController = streamController,
        _reminderRepository = reminderRepository,
        _eventTypeRepository = eventTypeRepository,
        _plantRepository = plantRepository,
        _speciesRepository = speciesRepository {
    load = Command.createAsyncNoParam(() async {
      Result<void> result = await _load();
      if (result.isError()) throw result.exceptionOrNull()!;
    }, initialValue: null);
    insert = Command.createAsyncNoParam(() async {
      Result<void> result = await _insert();
      if (result.isError()) throw result.exceptionOrNull()!;
      streamController.add(StreamCode.insertReminder);
    }, initialValue: null);
  }

  final ReminderRepository _reminderRepository;
  final ReminderSuggestionService _reminderSuggestionService;
  final StreamController<StreamCode> _streamController;
  final EventTypeRepository _eventTypeRepository;
  final PlantRepository _plantRepository;
  final SpeciesRepository _speciesRepository;
  final _log = Logger('AddReminderViewModel');

  late final Command<void, void> load;
  late final Command<void, void> insert;

  RemindersCompanion _remindersCompanion = RemindersCompanion(
    startDate: Value(DateTime.now()),
    frequencyQuantity: Value(1),
    frequencyUnit: Value(FrequencyUnit.weeks),
    repeatAfterQuantity: Value(3),
    repeatAfterUnit: Value(FrequencyUnit.days),
    enabled: Value(true),
  );
  final Map<int, EventType> _eventTypes = {};
  final Map<int, Plant> _plants = {};
  final Map<int, Specy> _species = {};

  Map<int, EventType> get eventTypes => _eventTypes;
  Map<int, Plant> get plants => _plants;
  Map<int, Specy> get species => _species;

  Future<Result<void>> _load() async {
    Result<List<EventType>> eventTypes = await _eventTypeRepository.getAll();
    if (eventTypes.isError()) return eventTypes;
    for (EventType et in eventTypes.getOrThrow()) {
      _eventTypes.putIfAbsent(et.id, () => et);
    }
    _log.fine("Event types loaded");

    Result<List<Plant>> plants = await _plantRepository.getAll();
    if (plants.isError()) return plants;
    for (Plant p in plants.getOrThrow()) {
      _plants.putIfAbsent(p.id, () => p);
    }
    _log.fine("Plants loaded");

    Result<List<Specy>> species = await _speciesRepository.getAll();
    if (species.isError()) return species;
    for (Specy s in species.getOrThrow()) {
      _species.putIfAbsent(s.id, () => s);
    }
    _log.fine("Specy loaded");

    notifyListeners();
    return Success("ok");
  }

  /// Reminders that fit the care of [plant], the season and its location.
  Future<List<ReminderSuggestion>> suggestionsFor(Plant plant) =>
      _reminderSuggestionService.suggest(plant);

  /// The event type of a suggestion, created if it was deleted or renamed.
  Future<Result<EventType>> _eventTypeFor(SuggestionKind kind) async {
    String name = suggestionEventTypes[kind]!;
    for (EventType type in _eventTypes.values) {
      if (type.name == name) return Success(type);
    }
    Result<int> id = await _eventTypeRepository.insert(EventTypesCompanion(
      name: Value(name),
      icon: const Value('sprout'),
      color: const Value('#81C784'),
    ));
    if (id.isError()) return Failure(id.exceptionOrNull()!);
    Result<EventType> type = await _eventTypeRepository.get(id.getOrThrow());
    if (type.isSuccess()) {
      _eventTypes[type.getOrThrow().id] = type.getOrThrow();
    }
    return type;
  }

  /// Creates the reminder of [suggestion] for [plant].
  Future<Result<void>> createSuggested(
      Plant plant, ReminderSuggestion suggestion) async {
    Result<EventType> type = await _eventTypeFor(suggestion.kind);
    if (type.isError()) return type;
    // Remind again sooner for frequent care
    (int, FrequencyUnit) repeatAfter = switch (suggestion.frequencyUnit) {
      FrequencyUnit.days => (1, FrequencyUnit.days),
      FrequencyUnit.weeks => (3, FrequencyUnit.days),
      _ => (7, FrequencyUnit.days),
    };
    Result<int> inserted = await _reminderRepository.insert(RemindersCompanion(
      type: Value(type.getOrThrow().id),
      plant: Value(plant.id),
      startDate: Value(suggestion.start),
      endDate: Value(suggestion.end),
      frequencyQuantity: Value(suggestion.frequencyQuantity),
      frequencyUnit: Value(suggestion.frequencyUnit),
      repeatAfterQuantity: Value(repeatAfter.$1),
      repeatAfterUnit: Value(repeatAfter.$2),
      enabled: const Value(true),
    ));
    if (inserted.isError()) return Failure(inserted.exceptionOrNull()!);
    _streamController.add(StreamCode.insertReminder);
    return Success("ok");
  }

  Future<Result<void>> _insert() async {
    return _reminderRepository.insert(_remindersCompanion);
  }

  void setType(EventType eventType) {
    _remindersCompanion =
        _remindersCompanion.copyWith(type: Value(eventType.id));
  }

  void setPlant(Plant plant) {
    _remindersCompanion = _remindersCompanion.copyWith(plant: Value(plant.id));
  }

  void setStart(DateTime start) {
    _remindersCompanion = _remindersCompanion.copyWith(startDate: Value(start));
  }

  void setEnd(DateTime end) {
    _remindersCompanion = _remindersCompanion.copyWith(endDate: Value(end));
  }

  void setFrequencyUnit(FrequencyUnit unit) {
    _remindersCompanion =
        _remindersCompanion.copyWith(frequencyUnit: Value(unit));
  }

  void setFrequencyQuantity(int quantity) {
    _remindersCompanion =
        _remindersCompanion.copyWith(frequencyQuantity: Value(quantity));
  }

  void setRepeatAfterUnit(FrequencyUnit unit) {
    _remindersCompanion =
        _remindersCompanion.copyWith(repeatAfterUnit: Value(unit));
  }

  void setRepeatAfterQuantity(int quantity) {
    _remindersCompanion =
        _remindersCompanion.copyWith(repeatAfterQuantity: Value(quantity));
  }

  void setEnabled(bool enabled) {
    _remindersCompanion = _remindersCompanion.copyWith(enabled: Value(enabled));
  }
}
