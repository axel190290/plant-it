import 'package:command_it/command_it.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/plant_groups.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/ui/core/ui/create_care_field_dialog.dart';
import 'package:plant_it/ui/core/ui/error_indicator.dart';
import 'package:plant_it/ui/core/ui/plant_group_format.dart';
import 'package:plant_it/ui/species/view_models/edit_care_values_viewmodel.dart';
import 'package:result_dart/result_dart.dart';

/// Edits the whole care of a species: basic care and care categories.
class EditCareValuesScreen extends StatelessWidget {
  final EditCareValuesViewModel viewModel;

  const EditCareValuesScreen({super.key, required this.viewModel});

  Future<void> _save(BuildContext context) async {
    String message;
    bool saved = false;
    try {
      await viewModel.save.executeWithFuture();
      if (!context.mounted) return;
      message = L.of(context).careSaved;
      saved = true;
    } catch (e) {
      if (!context.mounted) return;
      message = L.of(context).errorWithMessage(e.toString());
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (saved) {
      context.pop();
    }
  }

  Future<void> _addField(BuildContext context) async {
    CareFieldDraft? draft = await showCreateCareFieldDialog(context);
    if (draft == null) return;
    Result<void> result = await viewModel.addField(draft);
    if (result.isError() && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(L
              .of(context)
              .errorWithMessage(result.exceptionOrNull().toString()))));
    }
  }

  Future<void> _fillWithAi(BuildContext context) async {
    L l = L.of(context);
    if (!viewModel.aiAvailable) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.aiNotConfigured)));
      return;
    }
    Result<int> result = await viewModel.fillWithAi();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.isSuccess()
            ? l.aiFilledValues(result.getOrThrow())
            : l.errorWithMessage(result.exceptionOrNull().toString()))));
  }

  Future<void> _fillWithGroup(BuildContext context) async {
    L l = L.of(context);
    int filled = await viewModel.fillWithGroup();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.groupFilledValues(filled))));
  }

  Widget _aiCard(BuildContext context) {
    L l = L.of(context);
    PlantGroup? group = viewModel.group;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.fillWithAiHint,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            if (group != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _fillWithGroup(context),
                  icon: const Icon(LucideIcons.book_open),
                  label: Text(l.fillWithGroup(plantGroupName(l, group.id))),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: viewModel.filling
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator()),
                    )
                  : FilledButton.tonalIcon(
                      onPressed: () => _fillWithAi(context),
                      icon: const Icon(LucideIcons.sparkles),
                      label: Text(l.fillWithAi),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(String key, IconData fallback) {
    CareField? field = viewModel.basicField(key);
    return field == null ? fallback : careFieldIcon(field);
  }

  List<Widget> _basicCare(BuildContext context) {
    L l = L.of(context);
    SpeciesCareCompanion care = viewModel.care;
    return [
      _BasicCareEditor(
        icon: _icon(basicLightKey, LucideIcons.sun),
        title: l.sunlight,
        isSet: care.light.value != null,
        valueText: care.light.value?.toString(),
        onAdd: () => viewModel.setCare(care.copyWith(light: const Value(5))),
        onClear: () =>
            viewModel.setCare(care.copyWith(light: const Value(null))),
        editor: Slider(
          min: 1,
          max: 10,
          divisions: 9,
          label: care.light.value?.toString(),
          value: (care.light.value ?? 5).toDouble(),
          onChanged: (v) =>
              viewModel.setCare(care.copyWith(light: Value(v.round()))),
        ),
      ),
      _BasicCareEditor(
        icon: _icon(basicHumidityKey, LucideIcons.spray_can),
        title: l.humidity,
        forSuggestions: true,
        isSet: care.humidity.value != null,
        valueText:
            care.humidity.value == null ? null : "${care.humidity.value}0%",
        onAdd: () => viewModel.setCare(care.copyWith(humidity: const Value(5))),
        onClear: () =>
            viewModel.setCare(care.copyWith(humidity: const Value(null))),
        editor: Slider(
          min: 0,
          max: 10,
          divisions: 10,
          label: "${care.humidity.value ?? 5}0%",
          value: (care.humidity.value ?? 5).toDouble(),
          onChanged: (v) =>
              viewModel.setCare(care.copyWith(humidity: Value(v.round()))),
        ),
      ),
      _BasicCareEditor(
        icon: _icon(basicTemperatureKey, LucideIcons.thermometer),
        title: l.temperature,
        forSuggestions: true,
        isSet: care.tempMin.value != null || care.tempMax.value != null,
        valueText: care.tempMin.value == null && care.tempMax.value == null
            ? null
            : "${care.tempMin.value ?? -30} - ${care.tempMax.value ?? 50} °C",
        onAdd: () => viewModel.setCare(
            care.copyWith(tempMin: const Value(10), tempMax: const Value(30))),
        onClear: () => viewModel.setCare(care.copyWith(
            tempMin: const Value(null), tempMax: const Value(null))),
        editor: RangeSlider(
          min: -30,
          max: 50,
          divisions: 80,
          labels: RangeLabels("${care.tempMin.value ?? 10} °C",
              "${care.tempMax.value ?? 30} °C"),
          values: RangeValues((care.tempMin.value ?? 10).toDouble(),
              (care.tempMax.value ?? 30).toDouble()),
          onChanged: (v) => viewModel.setCare(care.copyWith(
              tempMin: Value(v.start.round()), tempMax: Value(v.end.round()))),
        ),
      ),
      _BasicCareEditor(
        icon: _icon(basicPhKey, LucideIcons.test_tube),
        title: l.ph,
        isSet: care.phMin.value != null || care.phMax.value != null,
        valueText: care.phMin.value == null && care.phMax.value == null
            ? null
            : "${care.phMin.value ?? 0} - ${care.phMax.value ?? 14}",
        onAdd: () => viewModel.setCare(
            care.copyWith(phMin: const Value(6), phMax: const Value(7))),
        onClear: () => viewModel.setCare(
            care.copyWith(phMin: const Value(null), phMax: const Value(null))),
        editor: RangeSlider(
          min: 0,
          max: 14,
          divisions: 14,
          labels: RangeLabels(
              "${care.phMin.value ?? 6}", "${care.phMax.value ?? 7}"),
          values: RangeValues((care.phMin.value ?? 6).toDouble(),
              (care.phMax.value ?? 7).toDouble()),
          onChanged: (v) => viewModel.setCare(care.copyWith(
              phMin: Value(v.start.round()), phMax: Value(v.end.round()))),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.editCare),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: Text(l.save),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<CommandResult<int?, void>>(
          valueListenable: viewModel.load.results,
          builder: (context, command, _) {
            if (command.isExecuting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (command.hasError) {
              return ErrorIndicator(
                title: l.errorWithMessage(command.error.toString()),
                label: l.tryAgain,
                onPressed: () => context.pop(),
              );
            }
            return ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _aiCard(context),
                  const SizedBox(height: 16),
                  Text(l.basicCare,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ..._basicCare(context),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.careCategories,
                          style: Theme.of(context).textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () => _addField(context),
                        icon: const Icon(LucideIcons.plus),
                        label: Text(l.addCareField),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (viewModel.fields.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(l.noCareFieldsEnabled),
                    ),
                  ...viewModel.fields.map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CareValueEditor(
                          key: ValueKey('${field.id}-${viewModel.generation}'),
                          field: field,
                          initial: viewModel.valueOf(field.id),
                          onChanged: (v) => viewModel.setValue(field.id, v),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One of the basic care values, which can be left unset.
class _BasicCareEditor extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool forSuggestions;
  final bool isSet;
  final String? valueText;
  final VoidCallback onAdd;
  final VoidCallback onClear;
  final Widget editor;

  const _BasicCareEditor({
    required this.icon,
    required this.title,
    this.forSuggestions = false,
    required this.isSet,
    required this.valueText,
    required this.onAdd,
    required this.onClear,
    required this.editor,
  });

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      if (forSuggestions) const _SuggestionMark(),
                    ],
                  ),
                ),
                Text(
                  valueText ?? l.notSet,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                isSet
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        tooltip: l.remove,
                        onPressed: onClear,
                      )
                    : IconButton(
                        icon: const Icon(LucideIcons.plus),
                        tooltip: l.add,
                        onPressed: onAdd,
                      ),
              ],
            ),
            if (isSet) editor,
          ],
        ),
      ),
    );
  }
}

class _CareValueEditor extends StatefulWidget {
  final CareField field;
  final CareValue initial;
  final ValueChanged<CareValue> onChanged;

  const _CareValueEditor({
    super.key,
    required this.field,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_CareValueEditor> createState() => _CareValueEditorState();
}

class _CareValueEditorState extends State<_CareValueEditor> {
  late final TextEditingController _first;
  late final TextEditingController _second;
  String? _choice;

  static String _numberText(double? n) {
    if (n == null) return '';
    return n == n.roundToDouble() ? n.round().toString() : n.toString();
  }

  @override
  void initState() {
    super.initState();
    bool isText = widget.field.type == CareFieldType.text;
    _first = TextEditingController(
        text: isText
            ? widget.initial.text ?? ''
            : _numberText(widget.initial.value));
    _second = TextEditingController(text: _numberText(widget.initial.maxValue));
    _choice = widget.initial.text;
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

  void _notify() {
    CareValue value = switch (widget.field.type) {
      CareFieldType.number => CareValue(value: _parse(_first.text)),
      CareFieldType.range =>
        CareValue(value: _parse(_first.text), maxValue: _parse(_second.text)),
      CareFieldType.text =>
        CareValue(text: _first.text.trim().isEmpty ? null : _first.text.trim()),
      CareFieldType.choice => CareValue(text: _choice),
    };
    widget.onChanged(value);
  }

  /// A month, kept as its number in [controller].
  Widget _monthPicker(L l, TextEditingController controller, String label) {
    int? month = _parse(controller.text)?.round();
    return DropdownButtonFormField<int?>(
      value: month != null && month >= 1 && month <= 12 ? month : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('—')),
        for (int m = 1; m <= 12; m++)
          DropdownMenuItem<int?>(value: m, child: Text(monthName(l, m))),
      ],
      onChanged: (m) {
        setState(() => controller.text = m?.toString() ?? '');
        _notify();
      },
    );
  }

  String? _unitSuffix(L l) {
    String? unit = widget.field.unit;
    if (unit == null || unit.isEmpty) return null;
    return switch (unit) {
      'days' => null,
      'years' => l.careFieldUnitYears,
      _ => unit,
    };
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    String label = careFieldName(l, widget.field);
    if (widget.field.unit == 'days') {
      label = "$label (${l.everyNDays('n')})";
    }
    const TextInputType numberKeyboard =
        TextInputType.numberWithOptions(decimal: true, signed: true);
    Widget? mark =
        isSuggestionCareField(widget.field) ? const _SuggestionMark() : null;

    switch (widget.field.type) {
      case CareFieldType.number when widget.field.unit == 'month':
        int? month = _parse(_first.text)?.round();
        return DropdownButtonFormField<int?>(
          value: month != null && month >= 1 && month <= 12 ? month : null,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: mark,
            border: const OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('—')),
            for (int m = 1; m <= 12; m++)
              DropdownMenuItem<int?>(value: m, child: Text(monthName(l, m))),
          ],
          onChanged: (m) {
            setState(() => _first.text = m?.toString() ?? '');
            _notify();
          },
        );
      case CareFieldType.number:
        return TextField(
          controller: _first,
          keyboardType: numberKeyboard,
          decoration: InputDecoration(
            labelText: label,
            suffixText: _unitSuffix(l),
            suffixIcon: mark,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _notify(),
        );
      case CareFieldType.range when widget.field.unit == 'month':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                if (mark != null) mark,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _monthPicker(l, _first, l.start)),
                const SizedBox(width: 12),
                Expanded(child: _monthPicker(l, _second, l.end)),
              ],
            ),
          ],
        );
      case CareFieldType.range:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(label,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                if (mark != null) mark,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _first,
                    keyboardType: numberKeyboard,
                    decoration: InputDecoration(
                      labelText: l.min,
                      suffixText: _unitSuffix(l),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _notify(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _second,
                    keyboardType: numberKeyboard,
                    decoration: InputDecoration(
                      labelText: l.max,
                      suffixText: _unitSuffix(l),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _notify(),
                  ),
                ),
              ],
            ),
          ],
        );
      case CareFieldType.text:
        return TextField(
          controller: _first,
          minLines: 1,
          maxLines: 4,
          maxLength: 1000,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: mark,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _notify(),
        );
      case CareFieldType.choice:
        List<String> options = (widget.field.options ?? '')
            .split('|')
            .where((o) => o.isNotEmpty)
            .toList();
        if (_choice != null && !options.contains(_choice)) {
          options.add(_choice!);
        }
        return DropdownButtonFormField<String?>(
          value: _choice,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('—')),
            ...options.map(
                (o) => DropdownMenuItem<String?>(value: o, child: Text(o))),
          ],
          onChanged: (v) {
            setState(() => _choice = v);
            _notify();
          },
        );
    }
  }
}

/// Marks the categories that the reminder suggestions read.
class _SuggestionMark extends StatelessWidget {
  const _SuggestionMark();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: L.of(context).usedForSuggestions,
      triggerMode: TooltipTriggerMode.tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(LucideIcons.bell_ring,
            size: 16, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
