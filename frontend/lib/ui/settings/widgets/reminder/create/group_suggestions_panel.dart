import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';
import 'package:plant_it/ui/settings/widgets/reminder/create/reminder_suggestions_panel.dart';
import 'package:result_dart/result_dart.dart';

/// The reminders suggested for the plants of a group, one per care; tapping
/// one creates the reminders of every plant with that care, each with its
/// own frequency and seasons.
class GroupSuggestionsPanel extends StatelessWidget {
  final AddReminderViewModel viewModel;
  final Collection collection;

  const GroupSuggestionsPanel({
    super.key,
    required this.viewModel,
    required this.collection,
  });

  /// The suggestion of a plant in force today, or its next one.
  static ReminderSuggestion _current(List<ReminderSuggestion> suggestions) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    return suggestions.firstWhere((s) => s.covers(today),
        orElse: () => suggestions.first);
  }

  Future<void> _create(BuildContext context, SuggestionKind kind,
      Map<Plant, List<ReminderSuggestion>> byPlant) async {
    L l = L.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${suggestionTitle(l, kind)} · ${collection.name}"),
        content: SingleChildScrollView(
          child: Text(byPlant.entries
              .map((e) =>
                  "${e.key.name}: ${suggestionEvery(l, _current(e.value))}"
                  "${e.value.length > 1 ? ' (${e.value.length})' : ''}")
              .join('\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.create),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    Result<void> result = Success("ok");
    for (MapEntry<Plant, List<ReminderSuggestion>> e in byPlant.entries) {
      result = await viewModel.createSuggested(e.key, e.value);
      if (result.isError()) break;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.isError()
            ? l.errorWithMessage(result.exceptionOrNull().toString())
            : l.reminderCreated)));
    if (result.isSuccess()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    Map<int, List<ReminderSuggestion>>? all = viewModel.groupSuggestions;
    if (all == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    List<Plant> plants = viewModel.plantsOf(collection.id);
    // For each care, the suggestions of each plant that has it
    Map<SuggestionKind, Map<Plant, List<ReminderSuggestion>>> byKind = {};
    for (Plant plant in plants) {
      for (ReminderSuggestion s in all[plant.id] ?? const []) {
        byKind
            .putIfAbsent(s.kind, () => {})
            .putIfAbsent(plant, () => [])
            .add(s);
      }
    }
    List<SuggestionKind> kinds =
        SuggestionKind.values.where(byKind.containsKey).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l.suggestionsForPlant(collection.name),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(kinds.isEmpty ? l.noSuggestions : l.suggestionsHint,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        ...kinds.map((kind) {
          Map<Plant, List<ReminderSuggestion>> byPlant = byKind[kind]!;
          return Card.filled(
            child: ListTile(
              leading: Icon(suggestionIcon(kind)),
              title: Text(suggestionTitle(l, kind)),
              subtitle: Text([
                l.suggestedForPlants(byPlant.length, plants.length),
                ...byPlant.entries.map((e) =>
                    "${e.key.name}: ${suggestionEvery(l, _current(e.value))}"),
              ].join('\n')),
              isThreeLine: true,
              trailing: const Icon(LucideIcons.plus),
              onTap: () => _create(context, kind, byPlant),
            ),
          );
        }),
      ],
    );
  }
}
