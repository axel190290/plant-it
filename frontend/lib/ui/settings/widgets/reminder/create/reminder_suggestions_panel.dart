import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/weather_format.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';
import 'package:result_dart/result_dart.dart';

String suggestionTitle(L l, SuggestionKind kind) => switch (kind) {
      SuggestionKind.watering => l.suggestionWatering,
      SuggestionKind.fertilizing => l.suggestionFertilizing,
      SuggestionKind.pruning => l.suggestionPruning,
      SuggestionKind.repotting => l.suggestionRepotting,
      SuggestionKind.pestCheck => l.suggestionPestCheck,
      SuggestionKind.misting => l.suggestionMisting,
      SuggestionKind.protectFromCold => l.suggestionProtectFromCold,
      SuggestionKind.moveOutdoors => l.suggestionMoveOutdoors,
    };

String _reason(L l, SuggestionKind kind) => switch (kind) {
      SuggestionKind.watering => l.reasonWatering,
      SuggestionKind.fertilizing => l.reasonFertilizing,
      SuggestionKind.pruning => l.reasonPruning,
      SuggestionKind.repotting => l.reasonRepotting,
      SuggestionKind.pestCheck => l.reasonPestCheck,
      SuggestionKind.misting => l.reasonMisting,
      SuggestionKind.protectFromCold => l.reasonProtectFromCold,
      SuggestionKind.moveOutdoors => l.reasonMoveOutdoors,
    };

IconData _icon(SuggestionKind kind) => switch (kind) {
      SuggestionKind.watering => LucideIcons.droplet,
      SuggestionKind.fertilizing => LucideIcons.flask_conical,
      SuggestionKind.pruning => LucideIcons.scissors,
      SuggestionKind.repotting => LucideIcons.package_open,
      SuggestionKind.pestCheck => LucideIcons.bug,
      SuggestionKind.misting => LucideIcons.droplets,
      SuggestionKind.protectFromCold => LucideIcons.snowflake,
      SuggestionKind.moveOutdoors => LucideIcons.sun,
    };

/// "every 2 weeks"
String suggestionEvery(L l, ReminderSuggestion s) => switch (s.frequencyUnit) {
      FrequencyUnit.days => l.everyCountDays(s.frequencyQuantity),
      FrequencyUnit.weeks => l.everyCountWeeks(s.frequencyQuantity),
      FrequencyUnit.months => l.everyCountMonths(s.frequencyQuantity),
      FrequencyUnit.years => l.everyCountYears(s.frequencyQuantity),
    };

/// "Winter: every 2 weeks · from 1 Dec 2026 · until 28 Feb 2027"
String suggestionSchedule(L l, ReminderSuggestion s) {
  DateFormat date = DateFormat.yMMMd(l.localeName);
  String schedule = [
    suggestionEvery(l, s),
    l.fromDate(date.format(s.start)),
    if (s.end != null) l.untilDate(date.format(s.end!)),
  ].join(' · ');
  return s.season == null
      ? schedule
      : "${seasonLabel(l, s.season!)}: $schedule";
}

/// The reminders suggested for [plant], one per care with a reminder for
/// each season when it changes with them; tapping one creates them.
class ReminderSuggestionsPanel extends StatelessWidget {
  final AddReminderViewModel viewModel;
  final Plant plant;

  const ReminderSuggestionsPanel({
    super.key,
    required this.viewModel,
    required this.plant,
  });

  Future<void> _create(
      BuildContext context, List<ReminderSuggestion> group) async {
    L l = L.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${suggestionTitle(l, group.first.kind)} · ${plant.name}"),
        content: Text([
          ...group.map((s) => suggestionSchedule(l, s)),
          if (group.length > 1) l.remindersToCreate(group.length),
        ].join('\n\n')),
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

    Result<void> result = await viewModel.createSuggested(plant, group);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.isError()
            ? l.errorWithMessage(result.exceptionOrNull().toString())
            : l.reminderCreated)));
    if (result.isSuccess()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    L l = L.of(context);
    List<ReminderSuggestion>? suggestions = viewModel.suggestions;
    if (suggestions == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    Map<SuggestionKind, List<ReminderSuggestion>> groups = {};
    for (ReminderSuggestion s in suggestions) {
      groups.putIfAbsent(s.kind, () => []).add(s);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l.suggestionsForPlant(plant.name),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          suggestions.isEmpty ? l.noSuggestions : l.suggestionsHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...groups.values.map((group) => Card.filled(
              child: ListTile(
                leading: Icon(_icon(group.first.kind)),
                title: Text(suggestionTitle(l, group.first.kind)),
                subtitle: Text([
                  ...group.map((s) => suggestionSchedule(l, s)),
                  _reason(l, group.first.kind),
                ].join('\n')),
                isThreeLine: true,
                trailing: const Icon(LucideIcons.plus),
                onTap: () => _create(context, group),
              ),
            )),
      ],
    );
  }
}
