import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:plant_it/data/repository/care_field_repository.dart';
import 'package:plant_it/data/repository/event_repository.dart';
import 'package:plant_it/data/repository/event_type_repository.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/repository/species_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_note.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

class CreateEventFormViewModel extends ChangeNotifier {
  CreateEventFormViewModel({
    required EventRepository eventRepository,
    required PlantRepository plantRepository,
    required EventTypeRepository eventTypeRepository,
    required SpeciesRepository speciesRepository,
    required CareFieldRepository careFieldRepository,
    required SpeciesCareRepository speciesCareRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required StreamController<StreamCode> streamController,
  })  : _eventRepository = eventRepository,
        _careFieldRepository = careFieldRepository,
        _speciesCareRepository = speciesCareRepository,
        _speciesCareValueRepository = speciesCareValueRepository,
        _plantRepository = plantRepository,
        _eventTypeRepository = eventTypeRepository,
        _speciesRepository = speciesRepository,
        _streamController = streamController {
    _date = DateTime.now();
    load = Command.createAsyncNoParam(() async {
      Result<void> result = await _load();
      if (result.isError()) throw result.exceptionOrNull()!;
      return;
    }, initialValue: null);
    insert = Command.createAsyncNoParam(() async {
      Result<void> result = await _saveEvent();
      if (result.isError()) throw result.exceptionOrNull()!;
      return "ok";
    }, initialValue: "not started");
  }

  final EventRepository _eventRepository;
  final PlantRepository _plantRepository;
  final EventTypeRepository _eventTypeRepository;
  final SpeciesRepository _speciesRepository;
  final CareFieldRepository _careFieldRepository;
  final SpeciesCareRepository _speciesCareRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final _log = Logger('EventFormViewModel');
  final StreamController<StreamCode> _streamController;

  late final Command<void, void> load;
  late final Command<void, String> insert;

  List<Plant> _plants = [];
  List<EventType> _eventTypes = [];
  List<Plant> _selectedPlants = [];
  List<EventType> _selectedEventTypes = [];
  final Map<int, Specy> _species = {};
  String? _note;
  // Whether the note was written by the user, and not filled in
  bool _noteWritten = false;
  List<CareField> _careFields = [];
  // Care of the species of the chosen plant, loaded when it is chosen
  final Map<int, (SpeciesCareData?, Map<String, CareValue>)> _care = {};
  DateTime? _date;
  bool _isSubmitting = false;
  String? errorMessage;

  List<Plant> get plants => _plants;
  List<EventType> get eventTypes => _eventTypes;
  bool get isSubmitting => _isSubmitting;
  List<EventType> get selectedEventTypes => _selectedEventTypes;
  List<Plant> get selectedPlants => _selectedPlants;
  String? get note => _note;
  DateTime? get date => _date;

  Future<Result<void>> _load() async {
    final loadPlants = await _loadPlants();
    if (loadPlants.isError()) {
      return loadPlants.exceptionOrNull()!.toFailure();
    }
    final loadEventTypes = await _loadEventTypes();
    if (loadEventTypes.isError()) {
      return loadEventTypes.exceptionOrNull()!.toFailure();
    }
    final loadSpecies = await _loadSpecies();
    if (loadSpecies.isError()) {
      return loadSpecies.exceptionOrNull()!.toFailure();
    }
    _careFields = (await _careFieldRepository.getAll()).getOrDefault([]);
    notifyListeners();
    return Success("ok");
  }

  Future<Result<void>> _loadPlants() async {
    Result<List<Plant>> plants = await _plantRepository.getAll();
    if (plants.isError()) {
      _log.warning('Failed to load plants', plants.exceptionOrNull());
      return plants.exceptionOrNull()!.toFailure();
    }
    _plants = plants.getOrThrow();
    _log.fine('Loaded plants');
    return Success("ok");
  }

  Future<Result<void>> _loadEventTypes() async {
    Result<List<EventType>> eventTypes = await _eventTypeRepository.getAll();
    if (eventTypes.isError()) {
      _log.warning('Failed to load event types', eventTypes.exceptionOrNull());
      return eventTypes.exceptionOrNull()!.toFailure();
    }
    _eventTypes = eventTypes.getOrThrow();
    _log.fine('Loaded event types');
    return Success("ok");
  }

  Future<Result<void>> _loadSpecies() async {
    for (Plant plant in _plants) {
      Result<Specy> species = await _speciesRepository.get(plant.species);
      if (species.isError()) {
        _log.warning('Failed to load species', species.exceptionOrNull());
        return species.exceptionOrNull()!.toFailure();
      }
      _species.putIfAbsent(plant.id, () => species.getOrThrow());
    }
    return Success("ok");
  }

  void setPlantList(List<Plant> plants) {
    _selectedPlants = plants;
    notifyListeners();
    for (int species in plants.map((p) => p.species).toSet()) {
      _loadCare(species);
    }
  }

  Future<void> _loadCare(int species) async {
    if (_care.containsKey(species)) return;
    SpeciesCareData? care =
        (await _speciesCareRepository.get(species)).getOrNull();
    Map<String, CareValue> values =
        (await _speciesCareValueRepository.getBySpeciesKeyed(species))
            .getOrDefault({});
    _care[species] = (care, values);
  }

  /// Fills in the note with the care of the chosen plants that matters
  /// for the chosen types, unless the user wrote one. Only when the plants
  /// are of one species, since the note is the same for all of them.
  void fillNote(L l) {
    if (_noteWritten) return;
    Set<int> species = _selectedPlants.map((p) => p.species).toSet();
    (SpeciesCareData?, Map<String, CareValue>)? care =
        species.length == 1 ? _care[species.first] : null;
    _note = care == null
        ? null
        : careNote(l, _selectedEventTypes.map((t) => t.name), _careFields,
            care.$2, care.$1);
    notifyListeners();
  }

  bool isPlantSelected(Plant plant) {
    return _selectedPlants.contains(plant);
  }

  Specy getSpecies(int plantId) {
    return _species[plantId]!;
  }

  void setEventTypeList(List<EventType> eventTypes) {
    _selectedEventTypes = eventTypes;
    notifyListeners();
  }

  bool isEventTypeSelected(EventType eventType) {
    return _selectedEventTypes.contains(eventType);
  }

  void setNote(String newNote) {
    _note = newNote.trim().isEmpty ? null : newNote;
    _noteWritten = true;
    notifyListeners();
  }

  void setDate(DateTime newDate) {
    _date = newDate;
    notifyListeners();
  }

  Future<Result<void>> _saveEvent() async {
    if (_selectedPlants.isEmpty ||
        _selectedEventTypes.isEmpty ||
        _date == null) {
      return Failure(Exception("Missing required fields"));
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      for (Plant plant in _selectedPlants) {
        for (EventType type in _selectedEventTypes) {
          EventsCompanion companion = EventsCompanion.insert(
            type: type.id,
            plant: plant.id,
            date: _date!,
            note: Value(_note),
          );
          await _eventRepository.insert(companion);
        }
      }
      return const Success("ok");
    } catch (e) {
      errorMessage = e.toString();
      return Failure(Exception(errorMessage));
    } finally {
      _isSubmitting = false;
      _streamController.add(StreamCode.insertEvent);
      notifyListeners();
    }
  }
}
