/// Where the data of a species downloaded from an external source comes
/// from. It is stored in the species bibliography (so it is kept when the
/// species is added to the collection) with the format
/// `plantit-sources:species=gbif;care=openplantbook;ai=gemini:light,ph;group=aroids`.
class CareSources {
  static const String _prefix = "plantit-sources:";
  static const String openPlantbook = "openplantbook";

  /// Field groups that can be estimated by the AI
  static const String light = "light";
  static const String humidity = "humidity";
  static const String temperature = "temperature";
  static const String ph = "ph";

  final String? species;
  final String? care;
  final String? aiProvider;
  final List<String> aiFields;
  // The plant group whose typical care filled in missing values
  final String? group;

  const CareSources({
    this.species,
    this.care,
    this.aiProvider,
    this.aiFields = const [],
    this.group,
  });

  bool get hasAiEstimate => aiProvider != null && aiFields.isNotEmpty;

  CareSources copyWith({
    String? species,
    String? care,
    String? aiProvider,
    List<String>? aiFields,
    String? group,
  }) {
    return CareSources(
      species: species ?? this.species,
      care: care ?? this.care,
      aiProvider: aiProvider ?? this.aiProvider,
      aiFields: aiFields ?? this.aiFields,
      group: group ?? this.group,
    );
  }

  /// Groups care column names (tempMin, phMax, ...) into display groups.
  static List<String> groupFields(List<String> fields) {
    return [
      if (fields.contains('light')) light,
      if (fields.contains('humidity')) humidity,
      if (fields.contains('tempMin') || fields.contains('tempMax')) temperature,
      if (fields.contains('phMin') || fields.contains('phMax')) ph,
    ];
  }

  String encode() {
    List<String> parts = [
      if (species != null) "species=$species",
      if (care != null) "care=$care",
      // Kept without fields too: the AI may have filled only care fields
      if (aiProvider != null) "ai=$aiProvider:${aiFields.join(',')}",
      if (group != null) "group=$group",
    ];
    return "$_prefix${parts.join(';')}";
  }

  /// Null if [bibliography] was not written by [encode].
  static CareSources? decode(String? bibliography) {
    if (bibliography == null || !bibliography.startsWith(_prefix)) {
      return null;
    }
    String? species;
    String? care;
    String? aiProvider;
    List<String> aiFields = [];
    String? group;
    for (String part in bibliography.substring(_prefix.length).split(';')) {
      int eq = part.indexOf('=');
      if (eq < 0) {
        continue;
      }
      String key = part.substring(0, eq);
      String value = part.substring(eq + 1);
      if (key == "species") {
        species = value;
      } else if (key == "care") {
        care = value;
      } else if (key == "group") {
        group = value;
      } else if (key == "ai") {
        int colon = value.indexOf(':');
        if (colon > 0) {
          aiProvider = value.substring(0, colon);
          aiFields = value
              .substring(colon + 1)
              .split(',')
              .where((f) => f.isNotEmpty)
              .toList();
        }
      }
    }
    return CareSources(
      species: species,
      care: care,
      aiProvider: aiProvider,
      aiFields: aiFields,
      group: group,
    );
  }
}
