import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';

/// The last day to remind, if any; kept in the view model, which fills it
/// in from the suggestion of the chosen type.
class EndStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  // The chosen end: a date, or null inside to remove it
  final ValueNotifier<(DateTime?,)?> _ongoing = ValueNotifier(null);

  EndStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<EndStep> createState() => _EndStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    if (_ongoing.value == null) return;
    viewModel.setEnd(_ongoing.value!.$1);
    _ongoing.value = null;
  }

  @override
  String get title => appLocalizations.end;

  @override
  String get value => viewModel.endDate == null
      ? ""
      : DateFormat.yMMMd(appLocalizations.localeName)
          .format(viewModel.endDate!);

  @override
  void cancel() => _ongoing.value = null;

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(
      BuildContext context, AddReminderViewModel viewModel) async {
    if (viewModel.endDate != null) {
      // An end can be changed or removed
      L l = L.of(context);
      bool? change = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.end),
          content: Text(value),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.remove),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.edit),
            ),
          ],
        ),
      );
      if (change == null || !context.mounted) return;
      if (!change) {
        _ongoing.value = (null,);
        return;
      }
    }
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate ?? viewModel.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _ongoing.value = (picked,);
    }
  }
}

class _EndStepState extends State<EndStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
