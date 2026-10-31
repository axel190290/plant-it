import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/home/view_models/sensor_viewmodel.dart';
import 'package:plant_it/utils/stream_code.dart';

String _number(double n) =>
    n == n.roundToDouble() ? n.round().toString() : n.toStringAsFixed(1);

/// The plants whose soil, measured by a RainPoint sensor, is too dry.
class SensorAlerts extends StatefulWidget {
  final SensorViewModel viewModel;
  final StreamController<StreamCode> streamController;

  const SensorAlerts({
    super.key,
    required this.viewModel,
    required this.streamController,
  });

  @override
  State<SensorAlerts> createState() => _SensorAlertsState();
}

class _SensorAlertsState extends State<SensorAlerts> {
  late final StreamSubscription<StreamCode> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.streamController.stream.listen((code) {
      // The links or the care of the plants changed
      if (const [
        StreamCode.editPlant,
        StreamCode.insertPlant,
        StreamCode.deletePlant,
        StreamCode.editSpecies,
      ].contains(code)) {
        widget.viewModel.load.execute();
      }
    });
    widget.viewModel.load.results.addListener(_showRecorded);
  }

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    // Light events are named in the language of the app
    widget.viewModel.lightTypeName = L.of(context).lightEvent;
    widget.viewModel.load.execute();
  }

  void _showRecorded() {
    if (widget.viewModel.load.results.value.isExecuting) return;
    int recorded = widget.viewModel.recorded;
    int light = widget.viewModel.lightRecorded;
    if (!mounted || (recorded == 0 && light == 0)) return;
    L l = L.of(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text([
      if (recorded > 0) l.rainPointWateringsRecorded(recorded),
      if (light > 0) l.lightEventsRecorded(light),
    ].join(' · '))));
  }

  @override
  void dispose() {
    widget.viewModel.load.results.removeListener(_showRecorded);
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.alerts.isEmpty &&
            widget.viewModel.lowLight.isEmpty) {
          return const SizedBox();
        }
        Color onError = Theme.of(context).colorScheme.onErrorContainer;
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
          child: Column(
            children: [
              ...widget.viewModel.lowLight.map((alert) => Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(LucideIcons.sun_dim, color: onError),
                      title: Text(
                        l.lowLightAlert(alert.plant, _number(alert.dli),
                            _number(alert.needed.$1), _number(alert.needed.$2)),
                        style: TextStyle(color: onError),
                      ),
                    ),
                  )),
              ...widget.viewModel.alerts.map((alert) => Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(LucideIcons.droplet_off, color: onError),
                      title: Text(
                        l.drySoilAlert(alert.plant, _number(alert.moisture),
                            _number(alert.min)),
                        style: TextStyle(color: onError),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
