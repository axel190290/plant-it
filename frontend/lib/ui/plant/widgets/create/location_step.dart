import 'package:flutter/material.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/plant/widgets/location_dialog.dart';
import 'package:plant_it/ui/plant/view_models/add_plant_viewmodel.dart';

class LocationStep extends StepSection<AddPlantViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  final ValueNotifier<String?> _selectedLocation = ValueNotifier(null);
  final ValueNotifier<String?> _ongoingSelection = ValueNotifier(null);

  LocationStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    viewModel.setLocation(_ongoingSelection.value);
    _selectedLocation.value = _ongoingSelection.value;
  }

  @override
  String get title => appLocalizations.location;

  @override
  String get value => _ongoingSelection.value == null
      ? ""
      : PlantLocation.label(appLocalizations, _ongoingSelection.value!);

  @override
  void cancel() {
    _ongoingSelection.value = _selectedLocation.value;
  }

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(BuildContext context, AddPlantViewModel viewModel) async {
    final String? result =
        await showPlantLocationDialog(context, _ongoingSelection.value);
    if (result != null) {
      _ongoingSelection.value = result.isEmpty ? null : result;
    }
  }
}

class _LocationStepState extends State<LocationStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
