import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
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
    required CollectionRepository collectionRepository,
  })  : _reminderSuggestionService = reminderSuggestionService,
        _collectionRepository = collectionRepository,
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
  final CollectionRepository _collectionRepository;
  final _log = Logger('AddReminderViewModel');

  late final Command<void, void> load;
  late final Command<void, void> insert;

  static RemindersCompanion _defaults() => RemindersCompanion(
        startDate: Value(DateTime.now()),
        frequencyQuantity: const Value(1),
        frequencyUnit: const Value(FrequencyUnit.weeks),
        repeatAfterQuantity: const Value(3),
        repeatAfterUnit: const Value(FrequencyUnit.days),
        enabled: const Value(true),
      );

  RemindersCompanion _remindersCompanion = _defaults();
  Plant? _plant;
  // A group chosen instead of a plant: a reminder is made for each plant
  Collection? _collection;
  List<Collection> _collections = [];
  Map<int, Set<int>> _plantsByCollection = {};
  // Suggestions of each plant of the chosen group, by plant id
  Map<int, List<ReminderSuggestion>>? _groupSuggestions;
  bool _perPlantSuggestions = true;
  List<ReminderSuggestion>? _suggestions;
  ReminderSuggestion? _applied;
  final Map<int, EventType> _eventTypes = {};
  final Map<int, Plant> _plants = {};
  final Map<int, Specy> _species = {};

  Map<int, EventType> get eventTypes => _eventTypes;
  Map<int, Plant> get plants => _plants;
  Map<int, Specy> get species => _species;

  Plant? get plant => _plant;
  Collection? get collection => _collection;
  List<Collection> get collections => _collections;

  /// The plants of the group [collectionId].
  List<Plant> plantsOf(int collectionId) => [
        for (int id in _plantsByCollection[collectionId] ?? const <int>{})
          if (_plants[id] != null) _plants[id]!
      ];

  /// For a group: whether each plant takes the values suggested for it,
  /// when it has them, instead of the same values for all.
  bool get perPlantSuggestions => _perPlantSuggestions;

  void setPerPlantSuggestions(bool value) {
    _perPlantSuggestions = value;
    notifyListeners();
  }

  /// For a group: how many of its plants have a suggestion for [type],
  /// null while they load.
  int? plantsWithSuggestion(EventType type) => _groupSuggestions?.values
      .where(
          (list) => list.any((s) => suggestionEventTypes[s.kind] == type.name))
      .length;

  /// The suggestions for the chosen plant, null while they load.
  List<ReminderSuggestion>? get suggestions => _suggestions;

  /// The suggestion whose values were filled in for the chosen type.
  ReminderSuggestion? get appliedSuggestion => _applied;

  int get frequencyQuantity => _remindersCompanion.frequencyQuantity.value;
  FrequencyUnit get frequencyUnit => _remindersCompanion.frequencyUnit.value;
  int get repeatAfterQuantity => _remindersCompanion.repeatAfterQuantity.value;
  FrequencyUnit get repeatAfterUnit =>
      _remindersCompanion.repeatAfterUnit.value;
  DateTime get startDate => _remindersCompanion.startDate.value;
  DateTime? get endDate => _remindersCompanion.endDate.present
      ? _remindersCompanion.endDate.value
      : null;

  /// The suggestion for [type]: the one in force today, or the next one.
  ReminderSuggestion? suggestionForType(EventType type) =>
      _currentSuggestion(_suggestions, type);

  static ReminderSuggestion? _currentSuggestion(
      List<ReminderSuggestion>? suggestions, EventType type) {
    List<ReminderSuggestion> matching = (suggestions ?? [])
        .where((s) => suggestionEventTypes[s.kind] == type.name)
        .toList();
    if (matching.isEmpty) return null;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return matching.firstWhere((s) => s.covers(today),
        orElse: () => matching.first);
  }

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

    _collections = (await _collectionRepository.getAll()).getOrDefault([]);
    _plantsByCollection =
        (await _collectionRepository.getPlantsByCollection()).getOrDefault({});

    notifyListeners();
    return Success("ok");
  }

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

  /// Remind again sooner for frequent care.
  static (int, FrequencyUnit) _repeatAfter(ReminderSuggestion suggestion) =>
      switch (suggestion.frequencyUnit) {
        FrequencyUnit.days => (1, FrequencyUnit.days),
        FrequencyUnit.weeks => (3, FrequencyUnit.days),
        _ => (7, FrequencyUnit.days),
      };

  /// Creates the reminders of [suggestions], the seasons of one care, for
  /// [plant].
  Future<Result<void>> createSuggested(
      Plant plant, List<ReminderSuggestion> suggestions) async {
    for (ReminderSuggestion suggestion in suggestions) {
      Result<EventType> type = await _eventTypeFor(suggestion.kind);
      if (type.isError()) return type;
      (int, FrequencyUnit) repeatAfter = _repeatAfter(suggestion);
      Result<int> inserted =
          await _reminderRepository.insert(RemindersCompanion(
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
    }
    _streamController.add(StreamCode.insertReminder);
    return Success("ok");
  }

  Future<Result<void>> _insert() async {
    if (_collection == null) {
      return _reminderRepository.insert(_remindersCompanion);
    }
    // One reminder per plant of the group
    List<Plant> plants = plantsOf(_collection!.id);
    if (plants.isEmpty) {
      return Failure(Exception("The group has no plants"));
    }
    EventType? type = _eventTypes[_remindersCompanion.type.value];
    for (Plant plant in plants) {
      ReminderSuggestion? suggestion = _perPlantSuggestions && type != null
          ? _currentSuggestion(_groupSuggestions?[plant.id], type)
          : null;
      RemindersCompanion reminder =
          _remindersCompanion.copyWith(plant: Value(plant.id));
      if (suggestion != null) {
        reminder = _withSuggestion(reminder, suggestion);
      }
      Result<int> inserted = await _reminderRepository.insert(reminder);
      if (inserted.isError()) return inserted;
    }
    return Success("ok");
  }

  static RemindersCompanion _withSuggestion(
      RemindersCompanion reminder, ReminderSuggestion suggestion) {
    (int, FrequencyUnit) repeatAfter = _repeatAfter(suggestion);
    return reminder.copyWith(
      startDate: Value(suggestion.start),
      endDate: Value(suggestion.end),
      frequencyQuantity: Value(suggestion.frequencyQuantity),
      frequencyUnit: Value(suggestion.frequencyUnit),
      repeatAfterQuantity: Value(repeatAfter.$1),
      repeatAfterUnit: Value(repeatAfter.$2),
    );
  }

  /// Chooses a group instead of a plant, and loads the suggestions of its
  /// plants.
  void setCollection(Collection collection) {
    if (_collection?.id == collection.id) return;
    _collection = collection;
    _plant = null;
    _suggestions = [];
    _groupSuggestions = null;
    notifyListeners();
    List<Plant> plants = plantsOf(collection.id);
    Future.wait(plants.map((p) => _reminderSuggestionService
        .suggest(p)
        .catchError((Object e) => <ReminderSuggestion>[]))).then((lists) {
      if (_collection?.id != collection.id) return;
      _groupSuggestions = {
        for (int i = 0; i < plants.length; i++) plants[i].id: lists[i]
      };
      notifyListeners();
    });
  }

  /// Chooses the type and fills in the values suggested for it, or the
  /// defaults when there is no suggestion.
  void setType(EventType eventType) {
    ReminderSuggestion? suggestion = suggestionForType(eventType);
    RemindersCompanion base = _defaults().copyWith(
      plant: _remindersCompanion.plant,
      type: Value(eventType.id),
    );
    if (suggestion != null) {
      base = _withSuggestion(base, suggestion);
    }
    _remindersCompanion = base;
    _applied = suggestion;
    notifyListeners();
  }

  /// Chooses the plant and loads the reminders suggested for it.
  void setPlant(Plant plant) {
    _remindersCompanion = _remindersCompanion.copyWith(plant: Value(plant.id));
    if (_plant?.id == plant.id) return;
    _plant = plant;
    _collection = null;
    _groupSuggestions = null;
    _suggestions = null;
    notifyListeners();
    _reminderSuggestionService.suggest(plant).then((suggestions) {
      if (_plant?.id != plant.id) return;
      _suggestions = suggestions;
      notifyListeners();
    }, onError: (Object e) {
      _log.warning("Suggestions failed", e);
      if (_plant?.id != plant.id) return;
      _suggestions = [];
      notifyListeners();
    });
  }

  void setStart(DateTime start) {
    _remindersCompanion = _remindersCompanion.copyWith(startDate: Value(start));
  }

  void setEnd(DateTime? end) {
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
