import 'package:command_it/command_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/ui/core/ui/create_care_field_dialog.dart';
import 'package:plant_it/ui/core/ui/error_indicator.dart';
import 'package:plant_it/ui/settings/view_models/care_fields_viewmodel.dart';
import 'package:result_dart/result_dart.dart';

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
    CareFieldDraft? draft = await showCreateCareFieldDialog(context);
    if (draft == null) return;
    Result<void> result = await viewModel.add(draft);
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
                  Widget toggle = Switch(
                    value: field.enabled,
                    onChanged: (enabled) async {
                      Result<void> result =
                          await viewModel.setEnabled(field, enabled);
                      if (context.mounted) _showError(context, result);
                    },
                  );
                  return ListTile(
                    title: Text(careFieldName(l, field)),
                    subtitle: Text(subtitle),
                    leading: Icon(careFieldIcon(field)),
                    onLongPress: custom ? () => _delete(context, field) : null,
                    trailing: custom
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.trash),
                                tooltip: l.delete,
                                onPressed: () => _delete(context, field),
                              ),
                              toggle,
                            ],
                          )
                        : toggle,
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
