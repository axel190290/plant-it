import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Soil moisture, in %, below which a plant whose care does not say it is
/// considered dry.
const double defaultSoilMoistureMin = 20;

String _number(double n) =>
    n == n.roundToDouble() ? n.round().toString() : n.toStringAsFixed(1);

/// What a device reported, in one line.
String rainPointSummary(L l, RainPointDevice device) {
  RainPointReading? r = device.reading;
  if (r == null || r.isEmpty) return l.noReading;
  List<String> parts = [];
  if (device.kind == RainPointKind.valve) {
    if (r.watering == true) {
      parts.add(l.wateringNow);
    } else if (r.eventTime != null && (r.lastWaterLiters ?? 0) > 0) {
      parts.add(l.lastWatering(
          DateFormat.yMMMd(l.localeName)
              .add_Hm()
              .format(r.eventTime!.toLocal()),
          _number(r.lastWaterLiters!)));
    }
  }
  if (r.soilMoisture != null) {
    parts.add(l.soilMoistureValue(_number(r.soilMoisture!)));
  }
  if (r.temperature != null) parts.add("${_number(r.temperature!)} °C");
  if (r.illuminance != null) parts.add("${_number(r.illuminance!)} lx");
  if (r.battery != null && r.battery! < 50) parts.add(l.lowBattery);
  return parts.isEmpty ? l.noReading : parts.join(' · ');
}

IconData rainPointIcon(RainPointDevice device) => switch (device.kind) {
      RainPointKind.soilSensor => LucideIcons.thermometer,
      RainPointKind.valve => LucideIcons.shower_head,
      _ => LucideIcons.router,
    };
