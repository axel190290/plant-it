import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';

/// The first day to remind; kept in the view model, which fills it in from
/// the suggestion of the chosen type.
class StartStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  final ValueNotifier<DateTime?> _ongoing = ValueNotifier(null);

  StartStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<StartStep> createState() => _StartStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    if (_ongoing.value == null) return;
    viewModel.setStart(_ongoing.value!);
    _ongoing.value = null;
  }

  @override
  String get title => appLocalizations.start;

  @override
  String get value =>
      DateFormat.yMMMd(appLocalizations.localeName).format(viewModel.startDate);

  @override
  void cancel() => _ongoing.value = null;

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(
      BuildContext context, AddReminderViewModel viewModel) async {
    _ongoing.value = await showDatePicker(
      context: context,
      initialDate: viewModel.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }
}

class _StartStepState extends State<StartStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
