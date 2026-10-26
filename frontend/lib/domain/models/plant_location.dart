import 'package:plant_it/l10n/generated/app_localizations.dart';

/// Where a plant lives, stored in the plant location.
abstract final class PlantLocation {
  static const String indoor = 'indoor';
  static const String outdoor = 'outdoor';
  static const List<String> values = [indoor, outdoor];

  /// The translated name, or the stored text for locations written before
  /// the location was a choice.
  static String label(L l, String location) => switch (location) {
        indoor => l.indoor,
        outdoor => l.outdoor,
        _ => location,
      };
}
