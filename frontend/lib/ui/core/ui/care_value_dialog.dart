import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Shows the whole value of a care tile, which may be cut in the tile.
void showCareValueDialog(
    BuildContext context, String title, String value, bool estimated) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(ctx).textTheme.bodyLarge),
          if (estimated) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.sparkles,
                    size: 14, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: 6),
                Text(L.of(ctx).estimatedByAi,
                    style: Theme.of(ctx).textTheme.bodySmall),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
        ),
      ],
    ),
  );
}
