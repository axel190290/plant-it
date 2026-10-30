import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Asks the name of a group of plants, starting from [initial].
Future<String?> showCollectionNameDialog(BuildContext context,
    {String? initial}) {
  L l = L.of(context);
  TextEditingController name = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(initial == null ? l.newCollection : l.renameCollection),
        content: TextField(
          controller: name,
          autofocus: true,
          maxLength: 50,
          decoration: InputDecoration(labelText: l.collectionName),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: name.text.trim().isEmpty
                ? null
                : () => Navigator.of(ctx).pop(name.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
}

/// Asks which of [options] to choose, starting from [selected]; null when
/// cancelled. [onCreate] adds a new option, if given.
Future<Set<int>?> showMultiPickDialog(
  BuildContext context, {
  required String title,
  required Map<int, String> options,
  required Set<int> selected,
  String? emptyText,
  Future<MapEntry<int, String>?> Function()? onCreate,
}) {
  L l = L.of(context);
  Map<int, String> shown = Map.of(options);
  Set<int> chosen = Set.of(selected);
  return showDialog<Set<int>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (shown.isEmpty && emptyText != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(emptyText),
                ),
              ...shown.entries.map((e) => CheckboxListTile(
                    value: chosen.contains(e.key),
                    title: Text(e.value),
                    onChanged: (v) => setState(() =>
                        v == true ? chosen.add(e.key) : chosen.remove(e.key)),
                  )),
              if (onCreate != null)
                ListTile(
                  leading: const Icon(LucideIcons.plus),
                  title: Text(l.newCollection),
                  onTap: () async {
                    MapEntry<int, String>? created = await onCreate();
                    if (created == null) return;
                    setState(() {
                      shown[created.key] = created.value;
                      chosen.add(created.key);
                    });
                  },
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
            onPressed: () => Navigator.of(ctx).pop(chosen),
            child: Text(l.save),
          ),
        ],
      ),
    ),
  );
}

/// Names of [collections] by id, in their order.
Map<int, String> collectionNames(List<Collection> collections) =>
    {for (Collection c in collections) c.id: c.name};
