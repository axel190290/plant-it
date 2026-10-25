import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/care_field_format.dart';
import 'package:plant_it/utils/icons.dart';

/// A care category described by the user, not saved yet.
class CareFieldDraft {
  final String name;
  final CareFieldType type;
  final String icon;
  final String? unit;
  final List<String> options;

  const CareFieldDraft({
    required this.name,
    required this.type,
    required this.icon,
    this.unit,
    this.options = const [],
  });

  CareFieldsCompanion toCompanion() {
    String? cleanUnit = unit?.trim();
    String joined = options
        .map((o) => o.trim().replaceAll('|', '/'))
        .where((o) => o.isNotEmpty)
        .join('|');
    return CareFieldsCompanion(
      name: Value(name.trim()),
      type: Value(type),
      icon: Value(icon),
      unit: Value(cleanUnit == null || cleanUnit.isEmpty ? null : cleanUnit),
      options: Value(type == CareFieldType.choice && joined.isNotEmpty
          ? (joined.length > 500 ? joined.substring(0, 500) : joined)
          : null),
    );
  }
}

String careFieldTypeName(L l, CareFieldType type) => switch (type) {
      CareFieldType.number => l.careFieldTypeNumber,
      CareFieldType.range => l.careFieldTypeRange,
      CareFieldType.text => l.careFieldTypeText,
      CareFieldType.choice => l.careFieldTypeChoice,
    };

/// Asks the name, type, icon and unit or options of a new care category.
Future<CareFieldDraft?> showCreateCareFieldDialog(BuildContext context) {
  L l = L.of(context);
  TextEditingController name = TextEditingController();
  TextEditingController unit = TextEditingController();
  TextEditingController options = TextEditingController();
  CareFieldType type = CareFieldType.text;
  String icon = customCareFieldIcons.first;

  return showDialog<CareFieldDraft>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l.addCareField),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 16),
              Text(l.icon, style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: customCareFieldIcons.map((name) {
                  bool selected = name == icon;
                  return IconButton(
                    isSelected: selected,
                    style: IconButton.styleFrom(
                      backgroundColor: selected
                          ? Theme.of(ctx).colorScheme.primaryContainer
                          : null,
                    ),
                    icon: Icon(appIcons[name]),
                    onPressed: () => setState(() => icon = name),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: name.text.trim().isEmpty
                ? null
                : () => Navigator.of(ctx).pop(CareFieldDraft(
                      name: name.text.trim(),
                      type: type,
                      icon: icon,
                      unit: unit.text,
                      options: options.text.split(','),
                    )),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
}
