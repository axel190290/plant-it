import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';

/// The plant to remind of, or a group to remind of each of its plants.
class PlantStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  // A Plant or a Collection
  final ValueNotifier<Object?> _selected = ValueNotifier(null);
  final ValueNotifier<Object?> _ongoingSelection = ValueNotifier(null);

  PlantStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<PlantStep> createState() => _PlantStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  String get title => appLocalizations.plant;

  @override
  String get value => switch (_ongoingSelection.value) {
        Plant plant => plant.name,
        Collection collection =>
          "${collection.name} (${viewModel.plantsOf(collection.id).length})",
        _ => "",
      };

  @override
  void confirm() {
    Object? selection = _ongoingSelection.value;
    if (selection is Plant) {
      viewModel.setPlant(selection);
    } else if (selection is Collection) {
      viewModel.setCollection(selection);
    }
    _selected.value = selection;
  }

  @override
  void cancel() {
    _ongoingSelection.value = _selected.value;
  }
}

class _PlantStepState extends State<PlantStep> {
  void _select(Object selection) {
    widget._ongoingSelection.value = selection;
    widget._isValidNotifier.value = true;
  }

  Widget _card({
    required bool selected,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card.outlined(
          shape: selected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          )),
    );
  }

  Widget _grid(List<Widget> children) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.7 / 2,
        children: children,
      );

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    // Groups with plants: a reminder is made for each of them
    List<Collection> collections = widget.viewModel.collections
        .where((c) => widget.viewModel.plantsOf(c.id).isNotEmpty)
        .toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.whichPlantsYouWantToSet,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedBuilder(
              animation: widget._ongoingSelection,
              builder: (context, _) {
                Object? selected = widget._ongoingSelection.value;
                return ListView(
                  children: [
                    if (collections.isNotEmpty) ...[
                      Text(l.plantCollections,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _grid(collections
                          .map((c) => _card(
                                selected: selected is Collection &&
                                    selected.id == c.id,
                                onTap: () => _select(c),
                                children: [
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.folder, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(c.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l.nPlants(
                                        widget.viewModel.plantsOf(c.id).length),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ))
                          .toList()),
                      const SizedBox(height: 16),
                      Text(l.plants,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                    ],
                    _grid(widget.viewModel.plants.values
                        .map((plant) => _card(
                              selected:
                                  selected is Plant && selected.id == plant.id,
                              onTap: () => _select(plant),
                              children: [
                                Text(plant.name),
                                const SizedBox(height: 8),
                                Text(
                                  widget.viewModel.species[plant.species]!
                                      .scientificName,
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ))
                        .toList()),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
