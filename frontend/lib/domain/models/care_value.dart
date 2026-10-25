import 'package:plant_it/database/database.dart';

/// The value of a care field for a species: a number ([value]), a range
/// ([value] to [maxValue]) or a text ([text], also used by choice fields).
class CareValue {
  final double? value;
  final double? maxValue;
  final String? text;
  // Estimated by an AI and not edited since
  final bool estimated;

  const CareValue({
    this.value,
    this.maxValue,
    this.text,
    this.estimated = false,
  });

  bool get isEmpty =>
      value == null && maxValue == null && (text == null || text!.isEmpty);

  CareValue copyWith({bool? estimated}) => CareValue(
        value: value,
        maxValue: maxValue,
        text: text,
        estimated: estimated ?? this.estimated,
      );

  Map<String, dynamic> toJson() => {
        'value': value,
        'maxValue': maxValue,
        'text': text,
        'estimated': estimated,
      };

  factory CareValue.fromJson(Map<String, dynamic> json) => CareValue(
        value: (json['value'] as num?)?.toDouble(),
        maxValue: (json['maxValue'] as num?)?.toDouble(),
        text: json['text'],
        estimated: json['estimated'] ?? false,
      );
}

/// Care read from a data source: the basic care of the species and the
/// values of built-in care fields by key.
class CareData {
  final SpeciesCareCompanion care;
  final Map<String, CareValue> extra;

  const CareData(this.care, this.extra);
}
