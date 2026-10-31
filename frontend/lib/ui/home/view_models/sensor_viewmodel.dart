import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/species_care_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_service.dart';
import 'package:plant_it/data/service/sensors/sensor_phone_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/light.dart';
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:plant_it/ui/core/ui/rainpoint_format.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// A plant whose soil is drier than its care wants.
class DrySoilAlert {
  final String plant;
  final double moisture;
  final double min;

  const DrySoilAlert(this.plant, this.moisture, this.min);
}

/// A plant that gets less light than its species wants.
class LowLightAlert {
  final String plant;
  final double dli;
  final (double, double) needed;

  const LowLightAlert(this.plant, this.dli, this.needed);
}

/// The RainPoint readings shown on home: the plants with dry soil. Loading
/// also records the waterings of the linked water timers.
class SensorViewModel extends ChangeNotifier {
  SensorViewModel({
    required RainPointService rainPointService,
    required PlantRepository plantRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required SpeciesCareRepository speciesCareRepository,
    required SensorPhoneService sensorPhoneService,
    required StreamController<StreamCode> streamController,
  })  : _rainPointService = rainPointService,
        _speciesCareRepository = speciesCareRepository,
        _sensorPhoneService = sensorPhoneService,
        _plantRepository = plantRepository,
        _speciesCareValueRepository = speciesCareValueRepository,
        _streamController = streamController {
    load = Command.createAsyncNoParam(() async {
      await _load();
    }, initialValue: null);
  }

  final RainPointService _rainPointService;
  final PlantRepository _plantRepository;
  final SpeciesCareValueRepository _speciesCareValueRepository;
  final SpeciesCareRepository _speciesCareRepository;
  final SensorPhoneService _sensorPhoneService;
  final StreamController<StreamCode> _streamController;

  late final Command<void, void> load;

  List<DrySoilAlert> _alerts = [];
  List<LowLightAlert> _lowLight = [];
  int _recorded = 0;

  List<DrySoilAlert> get alerts => _alerts;
  List<LowLightAlert> get lowLight => _lowLight;

  /// Waterings recorded by the last load.
  int get recorded => _recorded;

  Future<void> _load() async {
    _recorded = 0;
    _lowLight = await _lowLightAlerts();
    if (!await _rainPointService.isConfigured()) {
      _alerts = [];
      notifyListeners();
      return;
    }
    _recorded = await _rainPointService.recordWaterings();
    if (_recorded > 0) _streamController.add(StreamCode.insertEvent);

    Map<String, Set<int>> links = await _rainPointService.linkedPlants();
    Result<List<RainPointDevice>> devices = await _rainPointService.devices();
    Map<int, Plant> plants = {
      for (Plant p in (await _plantRepository.getAll()).getOrDefault([]))
        p.id: p
    };
    List<DrySoilAlert> alerts = [];
    for (RainPointDevice device in devices.getOrDefault([])) {
      double? moisture = device.reading?.soilMoisture;
      if (moisture == null) continue;
      for (int id in links[device.key] ?? const <int>{}) {
        Plant? plant = plants[id];
        if (plant == null) continue;
        Map<String, CareValue> values =
            (await _speciesCareValueRepository.getBySpeciesKeyed(plant.species))
                .getOrDefault({});
        double min = values['soil_moisture']?.value ?? defaultSoilMoistureMin;
        if (moisture < min) alerts.add(DrySoilAlert(plant.name, moisture, min));
      }
    }
    _alerts = alerts;
    notifyListeners();
  }

  /// The plants measured by a sensor phone that got, the last days, less
  /// light than their species wants.
  Future<List<LowLightAlert>> _lowLightAlerts() async {
    List<SensorPhone> phones = await _sensorPhoneService.phones();
    if (phones.isEmpty) return [];
    await _sensorPhoneService.sync();
    Map<String, Set<int>> linked = await _sensorPhoneService.linkedPlants();
    Map<int, Plant> plants = {
      for (Plant p in (await _plantRepository.getAll()).getOrDefault([]))
        p.id: p
    };
    List<LowLightAlert> alerts = [];
    for (SensorPhone phone in phones) {
      double? average = (await _sensorPhoneService.summary(phone)).averageDli;
      if (average == null) continue;
      for (int id in linked[phone.id] ?? const <int>{}) {
        Plant? plant = plants[id];
        if (plant == null) continue;
        SpeciesCareData? care =
            (await _speciesCareRepository.get(plant.species)).getOrNull();
        CareValue? lux =
            (await _speciesCareValueRepository.getBySpeciesKeyed(plant.species))
                .getOrDefault({})['light_lux'];
        (double, double)? needed = dliRange(
            light: care?.light, luxMin: lux?.value, luxMax: lux?.maxValue);
        if (needed != null && average < needed.$1) {
          alerts.add(LowLightAlert(plant.name, average, needed));
        }
      }
    }
    return alerts;
  }
}
