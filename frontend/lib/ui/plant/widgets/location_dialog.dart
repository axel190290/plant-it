import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/domain/models/plant_location.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Asks whether the plant is indoor or outdoor. Returns the chosen location,
/// an empty string to remove it, or null if cancelled.
Future<String?> showPlantLocationDialog(BuildContext context, String? current) {
  L l = L.of(context);
  return showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(l.location),
      children: [
        for (String location in PlantLocation.values)
          ListTile(
            leading: Icon(location == PlantLocation.indoor
                ? LucideIcons.house
                : LucideIcons.trees),
            title: Text(PlantLocation.label(l, location)),
            trailing: location == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(ctx).pop(location),
          ),
        ListTile(
          leading: const Icon(LucideIcons.x),
          title: Text(l.remove),
          onTap: () => Navigator.of(ctx).pop(''),
        ),
      ],
    ),
  );
}
