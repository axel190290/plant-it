import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/collection_dialogs.dart';
import 'package:plant_it/ui/home/view_models/home_viewmodel.dart';
import 'package:result_dart/result_dart.dart';

/// The groups of plants, to show only the plants of one. A long press on a
/// group chooses its plants, renames it or deletes it.
class CollectionChips extends StatelessWidget {
  final HomeViewModel viewModel;

  const CollectionChips({super.key, required this.viewModel});

  void _showError(BuildContext context, Result<Object?> result) {
    if (result.isError() && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(L
              .of(context)
              .errorWithMessage(result.exceptionOrNull().toString()))));
    }
  }

  Future<void> _create(BuildContext context) async {
    String? name = await showCollectionNameDialog(context);
    if (name == null || !context.mounted) return;
    Result<int> id = await viewModel.createCollection(name);
    if (!context.mounted) return;
    _showError(context, id);
    if (id.isSuccess()) {
      await _choosePlants(context, id.getOrThrow());
    }
  }

  Future<void> _choosePlants(BuildContext context, int collectionId) async {
    L l = L.of(context);
    Set<int>? plants = await showMultiPickDialog(
      context,
      title: l.choosePlants,
      options: {for (Plant p in viewModel.plants) p.id: p.name},
      selected: viewModel.plantsOf(collectionId),
    );
    if (plants == null || !context.mounted) return;
    _showError(
        context, await viewModel.setPlantsOfCollection(collectionId, plants));
  }

  Future<void> _showActions(BuildContext context, Collection collection) async {
    L l = L.of(context);
    String? action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(collection.name,
                  style: Theme.of(sheet).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(LucideIcons.list_checks),
              title: Text(l.choosePlants),
              onTap: () => Navigator.of(sheet).pop('plants'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: Text(l.renameCollection),
              onTap: () => Navigator.of(sheet).pop('rename'),
            ),
            ListTile(
              leading: const Icon(LucideIcons.trash),
              title: Text(l.deleteCollection),
              onTap: () => Navigator.of(sheet).pop('delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'plants':
        await _choosePlants(context, collection.id);
      case 'rename':
        String? name =
            await showCollectionNameDialog(context, initial: collection.name);
        if (name == null || !context.mounted) return;
        _showError(
            context, await viewModel.renameCollection(collection.id, name));
      case 'delete':
        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.deleteCollection),
            content: Text(l.deleteCollectionConfirm(collection.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.remove),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        _showError(context, await viewModel.deleteCollection(collection.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    int? selected = viewModel.selectedCollection;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: [
          ChoiceChip(
            label: Text("${l.allPlants} (${viewModel.plants.length})"),
            selected: selected == null,
            onSelected: (_) => viewModel.selectCollection(null),
          ),
          ...viewModel.collections.map((c) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onLongPress: () => _showActions(context, c),
                  child: ChoiceChip(
                    label:
                        Text("${c.name} (${viewModel.plantsOf(c.id).length})"),
                    selected: selected == c.id,
                    onSelected: (_) => viewModel.selectCollection(c.id),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ActionChip(
              avatar: const Icon(LucideIcons.plus, size: 16),
              label: Text(l.newCollection),
              onPressed: () => _create(context),
            ),
          ),
        ],
      ),
    );
  }
}
