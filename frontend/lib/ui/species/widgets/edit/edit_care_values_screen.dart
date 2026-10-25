import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_values_section.dart';
import 'package:plant_it/ui/core/ui/error_indicator.dart';
import 'package:plant_it/ui/species/view_models/edit_care_values_viewmodel.dart';

/// Edits the values of the enabled care fields of a species.
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

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.editMoreCare),
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
            if (viewModel.fields.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(l.noCareFieldsEnabled),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: viewModel.fields
                  .map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _CareValueEditor(
                          key: ValueKey(field.id),
                          field: field,
                          initial: viewModel.valueOf(field.id),
                          onChanged: (v) => viewModel.setValue(field.id, v),
                        ),
                      ))
                  .toList(),
            );
          },
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

  String? get _unitSuffix {
    String? unit = widget.field.unit;
    if (unit == null || unit.isEmpty) return null;
    return unit == 'days' ? null : unit;
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

    switch (widget.field.type) {
      case CareFieldType.number:
        return TextField(
          controller: _first,
          keyboardType: numberKeyboard,
          decoration: InputDecoration(
            labelText: label,
            suffixText: _unitSuffix,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => _notify(),
        );
      case CareFieldType.range:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _first,
                    keyboardType: numberKeyboard,
                    decoration: InputDecoration(
                      labelText: l.min,
                      suffixText: _unitSuffix,
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
                      suffixText: _unitSuffix,
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
