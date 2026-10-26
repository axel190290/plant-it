import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
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

/// "every 2 weeks · from 1 Mar 2027 · until 31 Aug 2027"
String suggestionSchedule(L l, ReminderSuggestion s) {
  String every = switch (s.frequencyUnit) {
    FrequencyUnit.days => l.everyCountDays(s.frequencyQuantity),
    FrequencyUnit.weeks => l.everyCountWeeks(s.frequencyQuantity),
    FrequencyUnit.months => l.everyCountMonths(s.frequencyQuantity),
    FrequencyUnit.years => l.everyCountYears(s.frequencyQuantity),
  };
  DateFormat date = DateFormat.yMMMd(l.localeName);
  return [
    every,
    l.fromDate(date.format(s.start)),
    if (s.end != null) l.untilDate(date.format(s.end!)),
  ].join(' · ');
}

/// The reminders suggested for [plant]; tapping one creates it.
class ReminderSuggestionsPanel extends StatefulWidget {
  final AddReminderViewModel viewModel;
  final Plant plant;

  const ReminderSuggestionsPanel({
    super.key,
    required this.viewModel,
    required this.plant,
  });

  @override
  State<ReminderSuggestionsPanel> createState() =>
      _ReminderSuggestionsPanelState();
}

class _ReminderSuggestionsPanelState extends State<ReminderSuggestionsPanel> {
  late final Future<List<ReminderSuggestion>> _suggestions =
      widget.viewModel.suggestionsFor(widget.plant);

  Future<void> _create(ReminderSuggestion suggestion) async {
    L l = L.of(context);
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            "${suggestionTitle(l, suggestion.kind)} · ${widget.plant.name}"),
        content: Text(suggestionSchedule(l, suggestion)),
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
    if (confirmed != true || !mounted) return;

    Result<void> result =
        await widget.viewModel.createSuggested(widget.plant, suggestion);
    if (!mounted) return;
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
    return FutureBuilder<List<ReminderSuggestion>>(
      future: _suggestions,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        List<ReminderSuggestion> suggestions = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(l.suggestionsForPlant(widget.plant.name),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              suggestions.isEmpty ? l.noSuggestions : l.suggestionsHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...suggestions.map((s) => Card.filled(
                  child: ListTile(
                    leading: Icon(_icon(s.kind)),
                    title: Text(suggestionTitle(l, s.kind)),
                    subtitle: Text(
                        "${suggestionSchedule(l, s)}\n${_reason(l, s.kind)}"),
                    isThreeLine: true,
                    trailing: const Icon(LucideIcons.plus),
                    onTap: () => _create(s),
                  ),
                )),
          ],
        );
      },
    );
  }
}
