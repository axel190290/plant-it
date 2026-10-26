import 'package:flutter/material.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Asks a quantity and a unit of time, starting from the given ones.
Future<(int, FrequencyUnit)?> showFrequencyDialog(
    BuildContext context, int quantity, FrequencyUnit unit) async {
  final TextEditingController controller =
      TextEditingController(text: quantity.toString());
  final ValueNotifier<FrequencyUnit> selected = ValueNotifier(unit);

  final String? result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                labelText: L.of(context).quantity,
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              autofocus: true,
            ),
            ValueListenableBuilder<FrequencyUnit>(
              valueListenable: selected,
              builder: (context, selectedUnit, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: FrequencyUnit.values.map((unit) {
                    return Row(
                      children: [
                        Radio<FrequencyUnit>(
                          value: unit,
                          groupValue: selectedUnit,
                          onChanged: (FrequencyUnit? value) {
                            if (value != null) {
                              selected.value = value;
                            }
                          },
                        ),
                        Text(unit.name.substring(0, 1).toUpperCase()),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(L.of(context).save),
          ),
        ],
      );
    },
  );
  if (result == null) return null;
  int parsed = int.tryParse(result.trim()) ?? quantity;
  return (parsed < 1 ? 1 : parsed, selected.value);
}
