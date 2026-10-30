import 'dart:async';

import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/repository/species_care_value_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
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

/// The RainPoint readings shown on home: the plants with dry soil. Loading
/// also records the waterings of the linked water timers.
class SensorViewModel extends ChangeNotifier {
  SensorViewModel({
    required RainPointService rainPointService,
    required PlantRepository plantRepository,
    required SpeciesCareValueRepository speciesCareValueRepository,
    required StreamController<StreamCode> streamController,
  })  : _rainPointService = rainPointService,
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
  final StreamController<StreamCode> _streamController;

  late final Command<void, void> load;

  List<DrySoilAlert> _alerts = [];
  int _recorded = 0;

  List<DrySoilAlert> get alerts => _alerts;

  /// Waterings recorded by the last load.
  int get recorded => _recorded;

  Future<void> _load() async {
    _recorded = 0;
    if (!await _rainPointService.isConfigured()) {
      _alerts = [];
      notifyListeners();
      return;
    }
    _recorded = await _rainPointService.recordWaterings();
    if (_recorded > 0) _streamController.add(StreamCode.insertEvent);

    Map<String, Set<int>> links = await _rainPointService.links();
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
}
