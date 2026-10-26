import 'package:flutter/material.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/settings/view_models/reminder/add_reminder_viewmodel.dart';
import 'package:plant_it/ui/settings/widgets/reminder/create/frequency_dialog.dart';

/// How often to remind; its value is kept in the view model, which fills
/// it in from the suggestion of the chosen type.
class FrequencyStep extends StepSection<AddReminderViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  final ValueNotifier<(int, FrequencyUnit)?> _ongoing = ValueNotifier(null);

  FrequencyStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<FrequencyStep> createState() => _FrequencyStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    if (_ongoing.value == null) return;
    viewModel.setFrequencyQuantity(_ongoing.value!.$1);
    viewModel.setFrequencyUnit(_ongoing.value!.$2);
    _ongoing.value = null;
  }

  @override
  String get title => appLocalizations.every;

  @override
  String get value => appLocalizations.frequency(
        viewModel.frequencyQuantity,
        viewModel.frequencyUnit.name,
      );

  @override
  void cancel() => _ongoing.value = null;

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(
      BuildContext context, AddReminderViewModel viewModel) async {
    _ongoing.value = await showFrequencyDialog(
        context, viewModel.frequencyQuantity, viewModel.frequencyUnit);
  }
}

class _FrequencyStepState extends State<FrequencyStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
