import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/data/service/weather/weather_service.dart';
import 'package:plant_it/domain/models/weather.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// Chooses the place of the local weather: by name or the device location.
class WeatherSettingsScreen extends StatefulWidget {
  final WeatherService weatherService;
  final StreamController<StreamCode> streamController;

  const WeatherSettingsScreen({
    super.key,
    required this.weatherService,
    required this.streamController,
  });

  @override
  State<WeatherSettingsScreen> createState() => _WeatherSettingsScreenState();
}

class _WeatherSettingsScreenState extends State<WeatherSettingsScreen> {
  final TextEditingController _search = TextEditingController();
  Place? _place;
  List<Place> _results = [];
  bool _busy = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    widget.weatherService.currentPlace().then((place) {
      if (mounted) setState(() => _place = place);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save(Place? place) async {
    Result<void> result = await widget.weatherService.setPlace(place);
    if (!mounted) return;
    if (result.isError()) {
      _showMessage(
          L.of(context).errorWithMessage(result.exceptionOrNull().toString()));
      return;
    }
    widget.streamController.add(StreamCode.editWeather);
    setState(() {
      _place = place;
      _results = [];
      _searched = false;
      _search.clear();
    });
  }

  Future<void> _searchPlaces() async {
    if (_search.text.trim().isEmpty) return;
    setState(() => _busy = true);
    Result<List<Place>> places =
        await widget.weatherService.searchPlaces(_search.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _searched = true;
      _results = places.getOrDefault([]);
    });
    if (places.isError()) {
      _showMessage(
          L.of(context).errorWithMessage(places.exceptionOrNull().toString()));
    }
  }

  Future<void> _useDeviceLocation() async {
    setState(() => _busy = true);
    Result<Place> place =
        await widget.weatherService.devicePlace(L.of(context).myLocation);
    if (!mounted) return;
    setState(() => _busy = false);
    if (place.isError()) {
      _showMessage(place.exceptionOrNull() is LocationPermissionException
          ? L.of(context).locationPermissionDenied
          : L.of(context).errorWithMessage(place.exceptionOrNull().toString()));
      return;
    }
    await _save(place.getOrThrow());
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.weatherAndLocation)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.weatherDescription),
            const SizedBox(height: 8),
            Text(l.outdoorAlertsHint,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Card.filled(
              child: ListTile(
                leading: const Icon(LucideIcons.map_pin),
                title: Text(_place?.name ?? l.noPlaceSet),
                subtitle: _place == null
                    ? null
                    : Text(
                        "${_place!.latitude.toStringAsFixed(2)}, ${_place!.longitude.toStringAsFixed(2)}"),
                trailing: _place == null
                    ? null
                    : IconButton(
                        icon: const Icon(LucideIcons.x),
                        tooltip: l.remove,
                        onPressed: () => _save(null),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : _useDeviceLocation,
              icon: const Icon(LucideIcons.locate_fixed),
              label: Text(l.useMyLocation),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchPlaces(),
              decoration: InputDecoration(
                labelText: l.searchCity,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _busy ? null : _searchPlaces,
                ),
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_searched && _results.isEmpty && !_busy)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.noPlacesFound),
              ),
            ..._results.map((place) => ListTile(
                  leading: const Icon(LucideIcons.map_pin),
                  title: Text(place.name),
                  onTap: () => _save(place),
                )),
          ],
        ),
      ),
    );
  }
}
