import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/database/database.dart';
import 'package:plant_it/domain/models/care_value.dart';
import 'package:plant_it/domain/models/reminder_suggestion.dart';
import 'package:plant_it/domain/models/user_settings_keys.dart';
import 'package:result_dart/result_dart.dart';

enum AiProvider {
  none('none', ''),
  claude('claude', 'Claude'),
  gemini('gemini', 'Gemini'),
  githubModels('github_models', 'GitHub Models');

  final String key;
  final String displayName;

  const AiProvider(this.key, this.displayName);

  static AiProvider fromKey(String? key) =>
      AiProvider.values.firstWhere((p) => p.key == key, orElse: () => none);

  String get defaultModel => switch (this) {
        AiProvider.none => '',
        AiProvider.claude => 'claude-opus-5-5',
        AiProvider.gemini => 'gemini-flash-latest',
        AiProvider.githubModels => 'openai/gpt-5-mini',
      };

  UserSettingsKeys? get keySetting => switch (this) {
        AiProvider.none => null,
        AiProvider.claude => UserSettingsKeys.claudeKey,
        AiProvider.gemini => UserSettingsKeys.geminiKey,
        AiProvider.githubModels => UserSettingsKeys.githubModelsToken,
      };

  UserSettingsKeys? get modelSetting => switch (this) {
        AiProvider.none => null,
        AiProvider.claude => UserSettingsKeys.claudeModel,
        AiProvider.gemini => UserSettingsKeys.geminiModel,
        AiProvider.githubModels => UserSettingsKeys.githubModelsModel,
      };
}

/// Estimates the care values of a species with the AI provider chosen by
/// the user. Only used to fill the values no real data source provides.
class AiCareEstimator {
  static const List<String> fields = [
    'light',
    'humidity',
    'tempMin',
    'tempMax',
    'phMin',
    'phMax',
  ];

  final UserSettingRepository _userSettingRepository;

  AiCareEstimator({
    required UserSettingRepository userSettingRepository,
  }) : _userSettingRepository = userSettingRepository;

  /// The provider to use, or [AiProvider.none] if it is not configured.
  Future<AiProvider> configuredProvider() async {
    AiProvider provider = AiProvider.fromKey((await _userSettingRepository
            .getOrDefault(UserSettingsKeys.aiProvider.key, AiProvider.none.key))
        .getOrDefault(AiProvider.none.key));
    if (provider == AiProvider.none) {
      return provider;
    }
    return (await _apiKey(provider)).isEmpty ? AiProvider.none : provider;
  }

  /// Sends [prompt] to [provider] and returns its JSON answer as text.
  Future<Result<String>> _ask(
      AiProvider provider, String prompt, Map<String, dynamic> schema) async {
    String apiKey = await _apiKey(provider);
    String model = (await _userSettingRepository.getOrDefault(
            provider.modelSetting!.key, ""))
        .getOrDefault("")
        .trim();
    if (model.isEmpty) {
      model = provider.defaultModel;
    }

    try {
      return switch (provider) {
        AiProvider.claude => await _askClaude(apiKey, model, prompt, schema),
        AiProvider.gemini => await _askGemini(apiKey, model, prompt),
        AiProvider.githubModels =>
          await _askGitHubModels(apiKey, model, prompt),
        AiProvider.none => Failure(Exception("No AI provider configured")),
      };
    } catch (e) {
      return Failure(
          Exception("Error while contacting ${provider.displayName}: $e"));
    }
  }

  /// Estimates the care of a species. The months of the year depend on
  /// the hemisphere, northern when [southernHemisphere] is unknown.
  Future<Result<CareData>> estimate(
      AiProvider provider, String scientificName, String? family,
      {bool? southernHemisphere}) async {
    Result<String> answer = await _ask(provider,
        _prompt(scientificName, family, southernHemisphere ?? false), _schema);
    if (answer.isError()) {
      return Failure(answer.exceptionOrNull()!);
    }
    Result<SpeciesCareCompanion> care = parseCare(answer.getOrThrow());
    if (care.isError()) {
      return Failure(care.exceptionOrNull()!);
    }
    return Success(
        CareData(care.getOrThrow(), parseExtraCare(answer.getOrThrow())));
  }

  static final Map<String, dynamic> _scheduleSchema = {
    'type': 'object',
    'properties': {
      'fertilizer_every': {
        'type': ['integer', 'null']
      },
      'fertilizer_unit': {
        'type': ['string', 'null'],
        'enum': ['days', 'weeks', 'months', null]
      },
      'pruning_month': {
        'type': ['integer', 'null']
      },
      'repotting_every_years': {
        'type': ['integer', 'null']
      },
      'repotting_month': {
        'type': ['integer', 'null']
      },
    },
    'required': [
      'fertilizer_every',
      'fertilizer_unit',
      'pruning_month',
      'repotting_every_years',
      'repotting_month'
    ],
    'additionalProperties': false,
  };

  /// Reads the schedule out of the fertilizer, pruning and repotting texts
  /// of a species, for the texts the rules could not read.
  Future<Result<ScheduleHints>> interpretSchedule(AiProvider provider,
      Map<String, String> texts, bool southernHemisphere) async {
    String hemisphere = southernHemisphere ? 'southern' : 'northern';
    String prompt = "These texts describe how to care for a plant in the "
        "$hemisphere hemisphere:\n"
        "${texts.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}\n"
        "Answer only with a JSON object with these fields, null when the "
        "text does not say it:\n"
        "- fertilizer_every and fertilizer_unit (days, weeks or months): how "
        "often to fertilize during the growing season\n"
        "- pruning_month: month (1-12) to prune\n"
        "- repotting_every_years: every how many years to repot\n"
        "- repotting_month: month (1-12) to repot";
    Result<String> answer = await _ask(provider, prompt, _scheduleSchema);
    if (answer.isError()) {
      return Failure(answer.exceptionOrNull()!);
    }
    return parseSchedule(answer.getOrThrow());
  }

  static Result<ScheduleHints> parseSchedule(String answer) {
    int start = answer.indexOf('{');
    int end = answer.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return Failure(Exception("The AI answer is not valid JSON"));
    }
    Map<String, dynamic> values;
    try {
      values = json.decode(answer.substring(start, end + 1));
    } catch (e) {
      return Failure(Exception("The AI answer is not valid JSON"));
    }
    int? read(String key, int min, int max) {
      dynamic v = values[key];
      int? n = v is num ? v.round() : (v is String ? int.tryParse(v) : null);
      return n == null || n < min || n > max ? null : n;
    }

    FrequencyUnit? unit = switch (values['fertilizer_unit']) {
      'days' => FrequencyUnit.days,
      'weeks' => FrequencyUnit.weeks,
      'months' => FrequencyUnit.months,
      _ => null,
    };
    int? every = read('fertilizer_every', 1, 365);
    return Success(ScheduleHints(
      fertilizerQuantity: unit == null ? null : every,
      fertilizerUnit: every == null ? null : unit,
      pruningMonth: read('pruning_month', 1, 12),
      repottingYears: read('repotting_every_years', 1, 10),
      repottingMonth: read('repotting_month', 1, 12),
    ));
  }

  Future<String> _apiKey(AiProvider provider) async {
    if (provider.keySetting == null) {
      return "";
    }
    return (await _userSettingRepository.getOrDefault(
            provider.keySetting!.key, ""))
        .getOrDefault("")
        .trim();
  }

  /// Built-in care fields the AI can estimate: numbers, then texts.
  static const List<String> numberFields = [
    'light_hours',
    'watering_summer',
    'watering_winter',
    'misting_every',
    'fertilizer_every',
    'pruning_month',
    'repotting_years',
    'repotting_month',
  ];

  /// Month ranges, asked as their first and last month: key, then the
  /// names of both in the answer.
  static const List<(String, String, String)> monthRangeFields = [
    ('flowering_months', 'flowering_from', 'flowering_to'),
    ('dormancy_months', 'dormancy_from', 'dormancy_to'),
  ];

  /// Valid range of each number field; values outside it are dropped.
  static const Map<String, (double, double)> _numberRanges = {
    'light_hours': (0, 24),
    'watering_summer': (1, 365),
    'watering_winter': (1, 365),
    'misting_every': (1, 60),
    'fertilizer_every': (1, 365),
    'pruning_month': (1, 12),
    'repotting_years': (1, 10),
    'repotting_month': (1, 12),
  };
  static const List<String> textFields = [
    'water_type',
    'watering_method',
    'substrate',
    'fertilizer',
    'pruning',
    'repotting',
    'flowering_season',
    'dormancy_season',
    'common_pests',
    'diseases',
    'toxicity',
    // Not care fields: the species description
    'description',
    'important_facts',
  ];

  static String _language() {
    const Map<String, String> names = {
      'es': 'Spanish',
      'en': 'English',
      'it': 'Italian',
      'fr': 'French',
      'de': 'German',
      'pt': 'Portuguese',
    };
    return names[PlatformDispatcher.instance.locale.languageCode] ?? 'English';
  }

  static String _prompt(
      String scientificName, String? family, bool southernHemisphere) {
    String familyText = family == null ? "" : " (family $family)";
    String hemisphere = southernHemisphere ? 'southern' : 'northern';
    return "Estimate the typical cultivation requirements of the plant "
        "species $scientificName$familyText, as grown at home or in a garden. "
        "Answer only with a JSON object with these fields:\n"
        "- light: integer from 1 (deep shade) to 10 (full direct sun all day)\n"
        "- humidity: integer, ideal ambient relative humidity in percent "
        "divided by 10, from 0 to 10\n"
        "- tempMin, tempMax: integers, tolerated temperature range in °C, "
        "between -30 and 50\n"
        "- phMin, phMax: integers, preferred soil pH range, between 0 and 14\n"
        "- light_hours: number, hours of light per day it needs\n"
        "- watering_summer, watering_winter: numbers, days between waterings "
        "in summer and in winter\n"
        "- misting_every: integer, days between mistings of its leaves; null "
        "if it does not need misting\n"
        "- fertilizer_every: integer, days between fertilizer applications "
        "during the growing season; null if it does not need fertilizer\n"
        "- pruning_month: integer 1-12, best month to prune it in the "
        "$hemisphere hemisphere; null if it does not need pruning\n"
        "- repotting_years: integer, years between repottings\n"
        "- repotting_month: integer 1-12, best month to repot it in the "
        "$hemisphere hemisphere\n"
        "- flowering_from, flowering_to: integers 1-12, first and last month "
        "of its flowering in the $hemisphere hemisphere; null if it does "
        "not flower at home\n"
        "- dormancy_from, dormancy_to: integers 1-12, first and last month "
        "of its rest period, when it needs less water and no fertilizer, in "
        "the $hemisphere hemisphere; null if it has none\n"
        "- water_type: the kind of water it prefers\n"
        "- watering_method: how to water it\n"
        "- substrate: the soil or mix it needs\n"
        "- fertilizer: kind of fertilizer and how often\n"
        "- pruning: when and how to prune it\n"
        "- repotting: how often and when to repot it\n"
        "- flowering_season, dormancy_season: months or seasons\n"
        "- common_pests: its usual pests\n"
        "- diseases: its usual diseases\n"
        "- toxicity: whether it is toxic for pets or people\n"
        "- description: two or three sentences presenting the plant: what it "
        "is known for, where it comes from and what it looks like\n"
        "- important_facts: two or three facts its owner should know, such as "
        "toxicity warnings or what yellow leaves mean, each on its own line "
        "starting with \"• \"\n"
        "Write the text fields in ${_language()}; except description and "
        "important_facts, in one short sentence each. "
        "Use null for any value you do not know with reasonable confidence.";
  }

  static final Map<String, dynamic> _schema = {
    'type': 'object',
    'properties': {
      'light': {
        'type': ['integer', 'null']
      },
      'humidity': {
        'type': ['integer', 'null']
      },
      'tempMin': {
        'type': ['integer', 'null']
      },
      'tempMax': {
        'type': ['integer', 'null']
      },
      'phMin': {
        'type': ['integer', 'null']
      },
      'phMax': {
        'type': ['integer', 'null']
      },
      for (String f in numberFields)
        f: {
          'type': ['number', 'null']
        },
      for ((String, String, String) f in monthRangeFields) ...{
        f.$2: {
          'type': ['integer', 'null']
        },
        f.$3: {
          'type': ['integer', 'null']
        },
      },
      for (String f in textFields)
        f: {
          'type': ['string', 'null']
        },
    },
    'required': [
      ...fields,
      ...numberFields,
      for ((String, String, String) f in monthRangeFields) ...[f.$2, f.$3],
      ...textFields
    ],
    'additionalProperties': false,
  };

  Future<Result<String>> _askClaude(String apiKey, String model, String prompt,
      Map<String, dynamic> schema) async {
    // Server-side fallback re-runs a declined request on another model
    bool supportsFallbacks = model.startsWith('claude-opus-5') ||
        model.startsWith('claude-fable-5-1') ||
        model.startsWith('claude-sonnet-5-5');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2026-10-21',
      if (supportsFallbacks)
        'anthropic-beta': 'server-side-fallback-2026-07-01',
    };
    Map<String, dynamic> body = {
      'model': model,
      'max_tokens': 8000,
      'output_config': {
        'effort': 'low',
        'format': {'type': 'json_schema', 'schema': schema},
      },
      if (supportsFallbacks) 'fallbacks': 'default',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
    };
    http.Response response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      return Failure(Exception(
          "Claude returned an error (${response.statusCode}): ${_errorMessage(response)}"));
    }
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    if (jsonResponse['stop_reason'] == 'refusal') {
      return Failure(Exception("Claude declined the request"));
    }
    List<dynamic> content = jsonResponse['content'] ?? [];
    String text = content
        .where((c) => c['type'] == 'text')
        .map((c) => c['text'] as String)
        .join();
    return Success(text);
  }

  Future<Result<String>> _askGemini(
      String apiKey, String model, String prompt) async {
    http.Response response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    if (response.statusCode != 200) {
      return Failure(Exception(
          "Gemini returned an error (${response.statusCode}): ${_errorMessage(response)}"));
    }
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    List<dynamic> parts =
        jsonResponse['candidates']?[0]?['content']?['parts'] ?? [];
    return Success(parts.map((p) => p['text'] ?? '').join());
  }

  Future<Result<String>> _askGitHubModels(
      String token, String model, String prompt) async {
    http.Response response = await http.post(
      Uri.parse('https://models.github.ai/inference/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github+json',
        'Authorization': 'Bearer $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      body: json.encode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'response_format': {'type': 'json_object'},
      }),
    );
    if (response.statusCode != 200) {
      return Failure(Exception(
          "GitHub Models returned an error (${response.statusCode}): ${_errorMessage(response)}"));
    }
    Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    return Success(jsonResponse['choices']?[0]?['message']?['content'] ?? '');
  }

  static String _errorMessage(http.Response response) {
    try {
      dynamic error = json.decode(utf8.decode(response.bodyBytes))['error'];
      if (error is Map) {
        return (error['message'] ?? error.toString()).toString();
      }
      return error?.toString() ?? response.reasonPhrase ?? '';
    } catch (_) {
      return response.reasonPhrase ?? '';
    }
  }

  /// Parses the model answer, tolerating text or code fences around the
  /// JSON, and clamps every value to the app scales.
  static Result<SpeciesCareCompanion> parseCare(String answer) {
    int start = answer.indexOf('{');
    int end = answer.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return Failure(Exception("The AI answer is not valid JSON"));
    }
    Map<String, dynamic> values;
    try {
      values = json.decode(answer.substring(start, end + 1));
    } catch (e) {
      return Failure(Exception("The AI answer is not valid JSON"));
    }

    int? read(String field, int min, int max) {
      dynamic v = values[field];
      if (v is num) {
        return v.round().clamp(min, max);
      }
      if (v is String) {
        num? parsed = num.tryParse(v);
        return parsed?.round().clamp(min, max);
      }
      return null;
    }

    return Success(SpeciesCareCompanion(
      species: const Value(-1),
      light: Value(read('light', 1, 10)),
      humidity: Value(read('humidity', 0, 10)),
      tempMin: Value(read('tempMin', -30, 50)),
      tempMax: Value(read('tempMax', -30, 50)),
      phMin: Value(read('phMin', 0, 14)),
      phMax: Value(read('phMax', 0, 14)),
    ));
  }

  /// Reads the built-in care fields of the model answer. Every value is
  /// marked as estimated.
  static Map<String, CareValue> parseExtraCare(String answer) {
    int start = answer.indexOf('{');
    int end = answer.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return {};
    }
    Map<String, dynamic> values;
    try {
      values = json.decode(answer.substring(start, end + 1));
    } catch (e) {
      return {};
    }
    Map<String, CareValue> result = {};
    for (String field in numberFields) {
      dynamic v = values[field];
      double? number =
          v is num ? v.toDouble() : (v is String ? double.tryParse(v) : null);
      (double, double) range = _numberRanges[field]!;
      if (number != null && number >= range.$1 && number <= range.$2) {
        // Months, years and days between cares are whole numbers
        if (field != 'light_hours') {
          number = number.roundToDouble();
        }
        result[field] = CareValue(value: number, estimated: true);
      }
    }
    for ((String, String, String) field in monthRangeFields) {
      int? month(String name) {
        dynamic v = values[name];
        int? n = v is num ? v.round() : (v is String ? int.tryParse(v) : null);
        return n == null || n < 1 || n > 12 ? null : n;
      }

      int? from = month(field.$2);
      int? to = month(field.$3);
      if (from != null && to != null) {
        result[field.$1] = CareValue(
            value: from.toDouble(), maxValue: to.toDouble(), estimated: true);
      }
    }
    for (String field in textFields) {
      dynamic v = values[field];
      if (v is String && v.trim().isNotEmpty) {
        String text = v.trim();
        result[field] = CareValue(
            text: text.length > 1000 ? text.substring(0, 1000) : text,
            estimated: true);
      }
    }
    return result;
  }
}
