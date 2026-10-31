import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/service/sensors/rainpoint_client.dart';
import 'package:plant_it/data/service/sensors/rainpoint_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/rainpoint.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/collection_dialogs.dart';
import 'package:plant_it/ui/core/ui/rainpoint_format.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// The RainPoint account, its devices and the plants each one is linked to.
class RainPointSettingsScreen extends StatefulWidget {
  final RainPointService rainPointService;
  final PlantRepository plantRepository;
  final CollectionRepository collectionRepository;
  final StreamController<StreamCode> streamController;

  const RainPointSettingsScreen({
    super.key,
    required this.rainPointService,
    required this.plantRepository,
    required this.collectionRepository,
    required this.streamController,
  });

  @override
  State<RainPointSettingsScreen> createState() =>
      _RainPointSettingsScreenState();
}

class _RainPointSettingsScreenState extends State<RainPointSettingsScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _areaCode = TextEditingController();
  String _app = RainPointClient.rainPointApp;
  bool _configured = false;
  bool _busy = false;
  List<RainPointDevice> _devices = [];
  Map<String, Set<int>> _links = {};
  // Plants by id, and groups of plants by their negated id
  Map<int, String> _plants = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _areaCode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    RainPointService service = widget.rainPointService;
    (String, String, String) account = await service.account();
    List<Plant> plants =
        (await widget.plantRepository.getAll()).getOrDefault([]);
    List<Collection> groups =
        (await widget.collectionRepository.getAll()).getOrDefault([]);
    Map<String, Set<int>> links = await service.links();
    bool configured = await service.isConfigured();
    if (!mounted) return;
    setState(() {
      _email.text = account.$1;
      _areaCode.text = account.$2;
      _app = account.$3;
      _configured = configured;
      // Groups first: a water timer usually waters a group of plants
      _plants = {
        for (Collection g in groups) -g.id: "📁 ${g.name}",
        for (Plant p in plants) p.id: p.name,
      };
      _links = links;
    });
    if (configured) await _refresh();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<Result<List<RainPointDevice>>> Function() action,
      {bool connecting = false}) async {
    setState(() => _busy = true);
    Result<List<RainPointDevice>> result = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result.isSuccess()) {
        _devices = result.getOrThrow();
        if (connecting) _configured = true;
      }
    });
    if (result.isError()) {
      _showMessage(
          L.of(context).errorWithMessage(result.exceptionOrNull().toString()));
    }
  }

  Future<void> _connect() async {
    await _run(
        () => widget.rainPointService.connect(
              email: _email.text,
              password: _password.text,
              areaCode: _areaCode.text,
              appCode: _app,
            ),
        connecting: true);
    _password.clear();
  }

  Future<void> _refresh() =>
      _run(() => widget.rainPointService.devices(refresh: true));

  Future<void> _disconnect() async {
    await widget.rainPointService.disconnect();
    if (!mounted) return;
    setState(() {
      _configured = false;
      _devices = [];
      _links = {};
    });
    widget.streamController.add(StreamCode.editPlant);
  }

  Future<void> _link(RainPointDevice device) async {
    L l = L.of(context);
    Set<int>? chosen = await showMultiPickDialog(
      context,
      title: device.name,
      options: _plants,
      selected: _links[device.key] ?? {},
    );
    if (chosen == null) return;
    await widget.rainPointService.setLinks(device.key, chosen);
    if (!mounted) return;
    setState(() => _links[device.key] = chosen);
    widget.streamController.add(StreamCode.editPlant);
    if (chosen.isEmpty) _showMessage(l.linkPlantsHint);
  }

  /// What the device reported, as received, to check its decoding.
  void _showStatus(RainPointDevice device) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${device.name} · ${device.model}"),
        content: SelectableText(device.status ?? '—'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.rainPoint),
        actions: [
          if (_configured)
            IconButton(
              tooltip: l.refresh,
              icon: const Icon(LucideIcons.refresh_cw),
              onPressed: _busy ? null : _refresh,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.rainPointHint),
            const SizedBox(height: 8),
            Card.outlined(
              child: ListTile(
                leading: const Icon(LucideIcons.triangle_alert),
                title: Text(l.rainPointSessionWarning,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                  labelText: l.email, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l.password,
                helperText: _configured ? l.passwordKeep : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaCode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: l.countryCode,
                  prefixText: '+',
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _app,
              decoration: InputDecoration(
                  labelText: l.rainPointAppLabel,
                  border: const OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                    value: RainPointClient.rainPointApp,
                    child: Text('RainPoint Home')),
                DropdownMenuItem(
                    value: RainPointClient.homGarApp, child: Text('HomGar')),
              ],
              onChanged: (v) => setState(() => _app = v ?? _app),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_configured)
                  TextButton(
                    onPressed: _busy ? null : _disconnect,
                    child: Text(l.disconnect),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy ? null : _connect,
                  child: Text(l.connect),
                ),
              ],
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_configured && !_busy) ...[
              const SizedBox(height: 16),
              Text(l.devices, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (_devices.isEmpty) Text(l.noRainPointDevices),
              ..._devices.map((device) {
                Set<int> linked = _links[device.key] ?? {};
                String plants = linked
                    .map((id) => _plants[id])
                    .whereType<String>()
                    .join(', ');
                return Card.filled(
                  child: ListTile(
                    leading: Icon(rainPointIcon(device)),
                    title: Text("${device.name} · ${device.model}"),
                    subtitle: Text([
                      rainPointSummary(l, device),
                      plants.isEmpty
                          ? l.linkPlantsHint
                          : l.linkedPlants(plants),
                    ].join('\n')),
                    isThreeLine: true,
                    trailing: const Icon(LucideIcons.link),
                    onTap: () => _link(device),
                    onLongPress: () => _showStatus(device),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
