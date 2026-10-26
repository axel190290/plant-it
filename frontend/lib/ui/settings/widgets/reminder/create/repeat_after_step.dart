import 'package:flutter/material.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';
import 'package:plant_it/ui/settings/widgets/reminder/create/frequency_dialog.dart';

/// How long to wait to remind again an undone event; kept in the view
/// model, which fills it in from the suggestion of the chosen type.
class RepeatAfterStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  final ValueNotifier<(int, FrequencyUnit)?> _ongoing = ValueNotifier(null);

  RepeatAfterStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<RepeatAfterStep> createState() => _RepeatAfterStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    if (_ongoing.value == null) return;
    viewModel.setRepeatAfterQuantity(_ongoing.value!.$1);
    viewModel.setRepeatAfterUnit(_ongoing.value!.$2);
    _ongoing.value = null;
  }

  @override
  String get title => appLocalizations.repeatAfter;

  @override
  String get value => appLocalizations.frequency(
        viewModel.repeatAfterQuantity,
        viewModel.repeatAfterUnit.name,
      );

  @override
  void cancel() => _ongoing.value = null;

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(
      BuildContext context, AddReminderViewModel viewModel) async {
    _ongoing.value = await showFrequencyDialog(
        context, viewModel.repeatAfterQuantity, viewModel.repeatAfterUnit);
  }
}

class _RepeatAfterStepState extends State<RepeatAfterStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
