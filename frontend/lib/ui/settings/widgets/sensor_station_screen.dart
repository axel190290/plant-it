import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/data/service/sensors/sensor_station.dart';
import 'package:plant_it/domain/models/light.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/light_format.dart';

/// This phone measuring the light next to the plants, for the phones paired
/// with it.
class SensorStationScreen extends StatefulWidget {
  final SensorStation station;

  const SensorStationScreen({super.key, required this.station});

  @override
  State<SensorStationScreen> createState() => _SensorStationScreenState();
}

class _SensorStationScreenState extends State<SensorStationScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    widget.station.load(defaultName: L.of(context).sensorPhone);
  }

  @override
  void dispose() {
    // Leaving the screen stops measuring and gives the screen back
    if (widget.station.running) widget.station.stop();
    super.dispose();
  }

  Future<void> _rename() async {
    L l = L.of(context);
    TextEditingController name =
        TextEditingController(text: widget.station.name);
    String? chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.sensorName),
        content: TextField(controller: name, autofocus: true, maxLength: 40),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(name.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (chosen != null) await widget.station.rename(chosen);
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return ListenableBuilder(
      listenable: widget.station,
      builder: (context, _) {
        SensorStation station = widget.station;
        bool running = station.running;
        Map<String, double?> now = station.current;
        TextStyle? big = Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: running ? Colors.white : null);
        TextStyle? small = Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: running ? Colors.white70 : null);
        double? azimuth = now['azimuth'];
        return Scaffold(
          // Black while measuring: the screen must not light the sensor
          backgroundColor: running ? Colors.black : null,
          appBar: running
              ? null
              : AppBar(
                  title: Text(l.sensorMode),
                  actions: [
                    IconButton(
                      tooltip: l.sensorName,
                      icon: const Icon(LucideIcons.pencil),
                      onPressed: _rename,
                    ),
                  ],
                ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!running) ...[
                  Text(station.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(l.sensorModeHint),
                  const SizedBox(height: 8),
                  Card.outlined(
                    child: ListTile(
                      leading: const Icon(LucideIcons.battery_warning),
                      title: Text(l.sensorBatteryWarning,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(l.luxValue(oneDecimal(now['lux'] ?? 0)), style: big),
                const SizedBox(height: 8),
                if (station.available['pressure'] == true &&
                    now['pressure'] != null)
                  Text(l.pressureValue(oneDecimal(now['pressure']!)),
                      style: small),
                if (now['batteryTemperature'] != null)
                  Text(
                      l.approxTemperature(
                          oneDecimal(now['batteryTemperature']!)),
                      style: small),
                if (azimuth != null)
                  Text(l.facing(compassName(l, compassPoint(azimuth))),
                      style: small),
                if (running) Text(l.readingsSaved(station.saved), style: small),
                const SizedBox(height: 24),
                Text(l.sensorPairInfo, style: small),
                const SizedBox(height: 4),
                for (String address in station.addresses)
                  Text(address, style: big),
                Text("${l.pairingCode}: ${station.code}", style: big),
                const SizedBox(height: 24),
                running
                    ? OutlinedButton.icon(
                        onPressed: station.stop,
                        icon: const Icon(LucideIcons.square),
                        label: Text(l.stopSensor),
                      )
                    : FilledButton.icon(
                        onPressed: station.available['light'] == false
                            ? null
                            : station.start,
                        icon: const Icon(LucideIcons.sun),
                        label: Text(l.startSensor),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
