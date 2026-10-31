import 'package:flutter/material.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';
import 'package:plant_it/ui/settings/widgets/reminder/create/group_suggestions_panel.dart';
import 'package:plant_it/ui/settings/widgets/reminder/create/reminder_suggestions_panel.dart';
import 'package:plant_it/utils/icons.dart';

class EventTypeStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(false);
  final ValueNotifier<EventType?> _selectedEventTypes = ValueNotifier(null);
  final ValueNotifier<EventType?> _ongoingSelection = ValueNotifier(null);

  EventTypeStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<EventTypeStep> createState() => _EventTypeStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  String get title => appLocalizations.eventType;

  @override
  String get value => _ongoingSelection.value?.name ?? "";

  @override
  void confirm() {
    viewModel.setType(_ongoingSelection.value!);
    _selectedEventTypes.value = _ongoingSelection.value;
  }

  @override
  void cancel() {
    _ongoingSelection.value = _selectedEventTypes.value;
  }
}

class _EventTypeStepState extends State<EventTypeStep> {
  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.whichEventTypeYouWantToSet,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 10),
        Expanded(
          child: AnimatedBuilder(
              animation: Listenable.merge(
                  [widget._ongoingSelection, widget.viewModel]),
              builder: (context, _) {
                Plant? plant = widget.viewModel.plant;
                Collection? collection = widget.viewModel.collection;
                return ListView(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3.7 / 2,
                      children: widget.viewModel.eventTypes.values
                          .map((eventType) => _typeCard(context, eventType))
                          .toList(),
                    ),
                    // Reminders that fit the chosen plant
                    if (plant != null)
                      ReminderSuggestionsPanel(
                        viewModel: widget.viewModel,
                        plant: plant,
                      ),
                    if (collection != null) ...[
                      GroupSuggestionsPanel(
                        viewModel: widget.viewModel,
                        collection: collection,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: widget.viewModel.perPlantSuggestions,
                        onChanged: widget.viewModel.setPerPlantSuggestions,
                        title: Text(l.perPlantSuggestions),
                      ),
                      Text(
                        widget.viewModel.perPlantSuggestions
                            ? l.perPlantSuggestionsHint(collection.name)
                            : l.remindersForGroup(collection.name),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                );
              }),
        ),
      ],
    );
  }

  Widget _typeCard(BuildContext context, EventType eventType) {
    bool isSelected = widget._ongoingSelection.value == eventType;
    Color primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        widget._ongoingSelection.value = eventType;
        widget._isValidNotifier.value = true;
      },
      child: Card.outlined(
          shape: isSelected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
                  side: BorderSide(color: primary, width: 2),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(appIcons[eventType.icon]),
                const SizedBox(height: 6),
                Text(eventType.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )),
    );
  }
}
