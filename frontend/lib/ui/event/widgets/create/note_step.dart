import 'package:flutter/material.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';
import 'package:plant_it/ui/core/ui/step_section.dart';
import 'package:plant_it/ui/event/view_models/event_viewmodel.dart';

class NoteStep extends StepSection<CreateEventFormViewModel> {
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier(true);
  // The note written in the dialog, until confirmed; the note itself is
  // kept in the view model, which fills it in from the care
  final ValueNotifier<String?> _ongoingSelection = ValueNotifier(null);

  NoteStep({
    super.key,
    required super.viewModel,
    required super.appLocalizations,
  });

  @override
  State<NoteStep> createState() => _NoteStepState();

  @override
  ValueNotifier<bool> get isValidNotifier => _isValidNotifier;

  @override
  void confirm() {
    if (_ongoingSelection.value == null) return;
    viewModel.setNote(_ongoingSelection.value!);
    _ongoingSelection.value = null;
  }

  @override
  String get title => appLocalizations.note;

  @override
  String get value {
    String note = viewModel.note ?? "";
    if (note.length > 20) {
      note = "${note.substring(0, 20)}...";
    }
    return note.replaceAll("\n", " ");
  }

  @override
  void cancel() {
    _ongoingSelection.value = null;
  }

  @override
  bool get isActionSection => true;

  @override
  Future<void> action(
      BuildContext context, CreateEventFormViewModel viewModel) async {
    final TextEditingController controller =
        TextEditingController(text: viewModel.note ?? "");
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: L.of(context).note,
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(L.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text(L.of(context).save),
            ),
          ],
        );
      },
    );

    if (result != null) {
      _ongoingSelection.value = result;
    }
  }
}

class _NoteStepState extends State<NoteStep> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
