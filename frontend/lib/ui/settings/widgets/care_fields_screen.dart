import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_values_section.dart';
import 'package:plant_it/ui/core/ui/error_indicator.dart';
import 'package:plant_it/ui/settings/view_models/care_fields_viewmodel.dart';
import 'package:result_dart/result_dart.dart';

String careFieldTypeName(L l, CareFieldType type) => switch (type) {
      CareFieldType.number => l.careFieldTypeNumber,
      CareFieldType.range => l.careFieldTypeRange,
      CareFieldType.text => l.careFieldTypeText,
      CareFieldType.choice => l.careFieldTypeChoice,
    };

/// Enables the built-in care fields and manages the ones created by the user.
class CareFieldsScreen extends StatelessWidget {
  final CareFieldsViewModel viewModel;

  const CareFieldsScreen({super.key, required this.viewModel});

  void _showError(BuildContext context, Result<void> result) {
    if (result.isError() && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(L
              .of(context)
              .errorWithMessage(result.exceptionOrNull().toString()))));
    }
  }

  Future<void> _add(BuildContext context) async {
    L l = L.of(context);
    TextEditingController name = TextEditingController();
    TextEditingController unit = TextEditingController();
    TextEditingController options = TextEditingController();
    CareFieldType type = CareFieldType.text;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l.addCareField),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  maxLength: 50,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l.name),
                  onChanged: (_) => setState(() {}),
                ),
                DropdownButtonFormField<CareFieldType>(
                  value: type,
                  decoration: InputDecoration(labelText: l.careFieldType),
                  items: CareFieldType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(careFieldTypeName(l, t))))
                      .toList(),
                  onChanged: (t) => setState(() => type = t ?? type),
                ),
                if (type == CareFieldType.number || type == CareFieldType.range)
                  TextField(
                    controller: unit,
                    maxLength: 20,
                    decoration: InputDecoration(labelText: l.careFieldUnit),
                  ),
                if (type == CareFieldType.choice)
                  TextField(
                    controller: options,
                    decoration: InputDecoration(labelText: l.careFieldOptions),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: name.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(ctx).pop(true),
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    Result<void> result = await viewModel.add(
      name: name.text,
      type: type,
      unit: unit.text,
      options: options.text.split(','),
    );
    if (context.mounted) _showError(context, result);
  }

  Future<void> _delete(BuildContext context, CareField field) async {
    L l = L.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.confirmDelete),
        content: Text(l.areYouSureYouWantToDeleteThisCareField),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    Result<void> result = await viewModel.delete(field);
    if (context.mounted) _showError(context, result);
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.careFields),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: l.addCareField,
            onPressed: () => _add(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<CommandResult<void, void>>(
          valueListenable: viewModel.load.results,
          builder: (context, command, _) {
            if (command.isExecuting && viewModel.fields.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (command.hasError) {
              return ErrorIndicator(
                title: l.errorWithMessage(command.error.toString()),
                label: l.tryAgain,
                onPressed: viewModel.load.execute,
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(l.careFieldsDescription),
                ),
                ...viewModel.fields.map((field) {
                  bool custom = field.key == null;
                  String subtitle = careFieldTypeName(l, field.type);
                  if (custom) {
                    subtitle = "$subtitle · ${l.customCareField}";
                  }
                  return ListTile(
                    title: Text(careFieldName(l, field)),
                    subtitle: Text(subtitle),
                    leading: custom
                        ? IconButton(
                            icon: const Icon(LucideIcons.trash),
                            tooltip: l.delete,
                            onPressed: () => _delete(context, field),
                          )
                        : null,
                    trailing: Switch(
                      value: field.enabled,
                      onChanged: (enabled) async {
                        Result<void> result =
                            await viewModel.setEnabled(field, enabled);
                        if (context.mounted) _showError(context, result);
                      },
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
