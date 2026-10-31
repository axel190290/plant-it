import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/data/repository/collection_repository.dart';
import 'package:plant_it/data/repository/plant_repository.dart';
import 'package:plant_it/data/service/sensors/sensor_phone_service.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/light.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/routing/routes.dart';
import 'package:plant_it/ui/core/ui/collection_dialogs.dart';
import 'package:plant_it/ui/core/ui/light_format.dart';
import 'package:plant_it/utils/stream_code.dart';
import 'package:result_dart/result_dart.dart';

/// The phones in sensor mode paired with this one and the plants each one
/// measures; also turns this phone into one.
class SensorPhonesScreen extends StatefulWidget {
  final SensorPhoneService sensorPhoneService;
  final PlantRepository plantRepository;
  final CollectionRepository collectionRepository;
  final StreamController<StreamCode> streamController;

  const SensorPhonesScreen({
    super.key,
    required this.sensorPhoneService,
    required this.plantRepository,
    required this.collectionRepository,
    required this.streamController,
  });

  @override
  State<SensorPhonesScreen> createState() => _SensorPhonesScreenState();
}

class _SensorPhonesScreenState extends State<SensorPhonesScreen> {
  List<SensorPhone> _phones = [];
  Map<String, LightSummary> _summaries = {};
  // Plants by id, and groups of plants by their negated id
  Map<int, String> _targets = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load(sync: true);
  }

  Future<void> _load({bool sync = false}) async {
    setState(() => _busy = true);
    SensorPhoneService service = widget.sensorPhoneService;
    if (sync) await service.sync();
    List<SensorPhone> phones = await service.phones();
    Map<String, LightSummary> summaries = {
      for (SensorPhone p in phones) p.id: await service.summary(p)
    };
    List<Plant> plants =
        (await widget.plantRepository.getAll()).getOrDefault([]);
    List<Collection> groups =
        (await widget.collectionRepository.getAll()).getOrDefault([]);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _phones = phones;
      _summaries = summaries;
      _targets = {
        for (Collection g in groups) -g.id: "📁 ${g.name}",
        for (Plant p in plants) p.id: p.name,
      };
    });
  }

  Future<void> _add() async {
    L l = L.of(context);
    TextEditingController address = TextEditingController();
    TextEditingController code = TextEditingController();
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addSensorPhone),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: address,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l.sensorAddress),
            ),
            TextField(
              controller: code,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l.pairingCode),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.add),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    Result<SensorPhone> added =
        await widget.sensorPhoneService.add(address.text, code.text);
    if (!mounted) return;
    if (added.isError()) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(l.errorWithMessage(added.exceptionOrNull().toString()))));
      return;
    }
    await _load();
    widget.streamController.add(StreamCode.editPlant);
  }

  Future<void> _link(SensorPhone phone) async {
    Set<int>? chosen = await showMultiPickDialog(
      context,
      title: phone.name,
      options: _targets,
      selected: phone.links,
    );
    if (chosen == null) return;
    await widget.sensorPhoneService.setLinks(phone.id, chosen);
    await _load();
    widget.streamController.add(StreamCode.editPlant);
  }

  Future<void> _remove(SensorPhone phone) async {
    await widget.sensorPhoneService.remove(phone.id);
    await _load();
    widget.streamController.add(StreamCode.editPlant);
  }

  String _describe(L l, SensorPhone phone) {
    LightSummary? summary = _summaries[phone.id];
    SensorReading? last = summary?.last;
    String linked =
        phone.links.map((id) => _targets[id]).whereType<String>().join(', ');
    return [
      if (last?.lux != null) l.luxValue(oneDecimal(last!.lux!)),
      if (summary?.todayDli != null) l.dliToday(oneDecimal(summary!.todayDli!)),
      if (phone.azimuth != null)
        l.facing(compassName(l, compassPoint(phone.azimuth!))),
      if (last != null)
        l.lastReading(
            '${MaterialLocalizations.of(context).formatShortMonthDay(last.time)} '
            '${TimeOfDay.fromDateTime(last.time).format(context)}'),
      linked.isEmpty ? l.linkPlantsHint : l.linkedPlants(linked),
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.sensorPhones),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(LucideIcons.refresh_cw),
            onPressed: _busy ? null : () => _load(sync: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _add,
        icon: const Icon(LucideIcons.plus),
        label: Text(l.addSensorPhone),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
          children: [
            Card.outlined(
              child: ListTile(
                leading: const Icon(LucideIcons.smartphone),
                title: Text(l.useAsSensor),
                subtitle: Text(l.useAsSensorHint),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => context.push(Routes.settingsSensorStation),
              ),
            ),
            const SizedBox(height: 8),
            if (_busy) const LinearProgressIndicator(),
            if (_phones.isEmpty && !_busy)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.noSensorPhones),
              ),
            ..._phones.map((phone) => Card.filled(
                  child: ListTile(
                    leading: const Icon(LucideIcons.sun),
                    title: Text(phone.name),
                    subtitle: Text(_describe(l, phone)),
                    isThreeLine: true,
                    onTap: () => _link(phone),
                    trailing: IconButton(
                      tooltip: l.remove,
                      icon: const Icon(LucideIcons.trash),
                      onPressed: () => _remove(phone),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
