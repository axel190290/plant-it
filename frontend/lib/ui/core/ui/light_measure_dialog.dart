import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plant_it/data/service/sensors/sensor_station.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/light_format.dart';

/// Measures the light with the sensor of this phone for a few seconds and
/// returns the average lux, or null when cancelled or without a sensor.
Future<double?> showLightMeasureDialog(BuildContext context, String title,
    {PhoneSensors sensors = const PhoneSensors()}) async {
  L l = L.of(context);
  Map<String, bool> available = await sensors.available();
  if (!context.mounted) return null;
  if (available['light'] != true) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.noLightSensor)));
    return null;
  }
  return showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LightMeasureDialog(title: title, sensors: sensors),
  );
}

class _LightMeasureDialog extends StatefulWidget {
  final String title;
  final PhoneSensors sensors;

  const _LightMeasureDialog({required this.title, required this.sensors});

  @override
  State<_LightMeasureDialog> createState() => _LightMeasureDialogState();
}

class _LightMeasureDialogState extends State<_LightMeasureDialog> {
  final List<double> _values = [];
  Timer? _timer;
  double? _now;

  @override
  void initState() {
    super.initState();
    widget.sensors.start(dimScreen: false).then((_) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
        double? lux = (await widget.sensors.read())['lux'];
        if (lux == null || !mounted) return;
        setState(() {
          _now = lux;
          _values.add(lux);
          // The last few seconds count
          if (_values.length > 10) _values.removeAt(0);
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.sensors.stop();
    super.dispose();
  }

  double? get _average => _values.isEmpty
      ? null
      : _values.reduce((a, b) => a + b) / _values.length;

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.measureLightHint),
          const SizedBox(height: 16),
          Text(
            _now == null ? '…' : l.luxValue(oneDecimal(_now!)),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _values.length < 4
              ? null
              : () => Navigator.of(context).pop(_average),
          child: Text(l.save),
        ),
      ],
    );
  }
}
