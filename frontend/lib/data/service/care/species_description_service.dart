import 'package:plant_it/data/service/care/ai_care_estimator.dart';
import 'package:plant_it/data/service/search/gbif_searcher.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:result_dart/result_dart.dart';

/// Builds the description of a species: a summary from Wikipedia (through
/// iNaturalist), or from the AI when there is none, followed by the
/// important facts given by the AI.
class SpeciesDescriptionService {
  static const int maxLength = 2000;

  final GbifSearcher _gbifSearcher;
  final AiCareEstimator _aiCareEstimator;

  SpeciesDescriptionService({
    required GbifSearcher gbifSearcher,
    required AiCareEstimator aiCareEstimator,
  })  : _gbifSearcher = gbifSearcher,
        _aiCareEstimator = aiCareEstimator;

  /// [aiValues] are the values already estimated by the AI for the species,
  /// if any; otherwise the AI is asked when configured.
  Future<String?> describe(String scientificName, String? family,
      {Map<String, CareValue>? aiValues}) async {
    String? summary = await _gbifSearcher.getSummary(scientificName);
    Map<String, CareValue> ai =
        aiValues ?? await _askAi(scientificName, family);
    return compose(
        summary, ai['description']?.text, ai['important_facts']?.text);
  }

  Future<Map<String, CareValue>> _askAi(
      String scientificName, String? family) async {
    AiProvider provider = await _aiCareEstimator.configuredProvider();
    if (provider == AiProvider.none) {
      return {};
    }
    Result<CareData> estimate =
        await _aiCareEstimator.estimate(provider, scientificName, family);
    return estimate.isSuccess() ? estimate.getOrThrow().extra : {};
  }

  static String? compose(
      String? summary, String? aiDescription, String? importantFacts) {
    String? intro = (summary ?? "").trim().isNotEmpty
        ? summary!.trim()
        : (aiDescription ?? "").trim().isNotEmpty
            ? aiDescription!.trim()
            : null;
    List<String> facts = (importantFacts ?? "")
        .split('\n')
        .map((f) => f.trim().replaceFirst(RegExp(r'^[•\-*]\s*'), ''))
        .where((f) => f.isNotEmpty)
        .map((f) => "• $f")
        .toList();
    String text = [
      if (intro != null) intro,
      if (facts.isNotEmpty) facts.join('\n')
    ].join('\n\n');
    if (text.isEmpty) {
      return null;
    }
    return text.length <= maxLength ? text : text.substring(0, maxLength);
  }
}
