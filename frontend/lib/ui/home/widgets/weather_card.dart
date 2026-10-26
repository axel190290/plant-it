import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/core/ui/weather_format.dart';
import 'package:plant_it/ui/home/view_models/weather_viewmodel.dart';
import 'package:plant_it/utils/stream_code.dart';

/// The local weather, the season and the alerts for the outdoor plants.
class WeatherCard extends StatefulWidget {
  final WeatherViewModel viewModel;
  final StreamController<StreamCode> streamController;

  const WeatherCard({
    super.key,
    required this.viewModel,
    required this.streamController,
  });

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  late final StreamSubscription<StreamCode> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.streamController.stream.listen((code) {
      // The place, the outdoor plants or their care changed
      if (const [
        StreamCode.editWeather,
        StreamCode.insertPlant,
        StreamCode.editPlant,
        StreamCode.deletePlant,
        StreamCode.editSpecies,
      ].contains(code)) {
        widget.viewModel.load.execute();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _showForecast(BuildContext context, Weather weather) {
    L l = L.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${l.forecast} · ${weather.place}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: weather.days
              .map((day) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(weatherIcon(day.weatherCode)),
                    title: Text(dayLabel(l, day.date)),
                    subtitle: Text([
                      weatherLabel(l, day.weatherCode),
                      if ((day.precipitation ?? 0) > 0)
                        "${day.precipitation!.toStringAsFixed(1)} mm",
                      if (day.precipitationProbability != null)
                        "${day.precipitationProbability}%",
                    ].join(' · ')),
                    trailing: Text(
                        "${temperatureText(day.min)} / ${temperatureText(day.max)}"),
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  String _alertText(L l, WeatherAlert alert) => switch (alert.type) {
        WeatherAlertType.frost => l.frostAlert(
            dayLabel(l, alert.day!.date),
            alert.temperature!.round().toString(),
            alert.plants.first,
            alert.limit.toString()),
        WeatherAlertType.heat => l.heatAlert(
            dayLabel(l, alert.day!.date),
            alert.temperature!.round().toString(),
            alert.plants.first,
            alert.limit.toString()),
        WeatherAlertType.rain => l.rainAlert(alert.plants.join(', ')),
      };

  IconData _alertIcon(WeatherAlertType type) => switch (type) {
        WeatherAlertType.frost => LucideIcons.snowflake,
        WeatherAlertType.heat => LucideIcons.thermometer_sun,
        WeatherAlertType.rain => LucideIcons.umbrella,
      };

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        Weather? weather = widget.viewModel.weather;
        if (!widget.viewModel.hasPlace) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
            child: Card.outlined(
              child: ListTile(
                leading: const Icon(LucideIcons.map_pin),
                title: Text(l.setUpWeather),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.push(Routes.settingsWeather),
              ),
            ),
          );
        }
        if (weather == null) {
          return const SizedBox();
        }
        DayForecast? today = weather.today;
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 12),
          child: Column(
            children: [
              Card.filled(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () => _showForecast(context, weather),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(weatherIcon(weather.weatherCode), size: 40),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${temperatureText(weather.temperature)} · ${weatherLabel(l, weather.weatherCode)}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                [
                                  if (weather.humidity != null)
                                    l.humidityPercent(
                                        weather.humidity.toString()),
                                  if (today != null)
                                    "${temperatureText(today.min)} / ${temperatureText(today.max)}",
                                ].join(' · '),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                "${seasonLabel(l, weather.season)} · ${weather.place}",
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...widget.viewModel.alerts.map((alert) => Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: Icon(_alertIcon(alert.type),
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                      title: Text(
                        _alertText(l, alert),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
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
