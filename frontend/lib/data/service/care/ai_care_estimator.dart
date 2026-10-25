import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:plant_it/data/repository/user_setting_repository.dart';
import 'package:plant_it/database/database.dart';
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

  Future<Result<SpeciesCareCompanion>> estimate(
      AiProvider provider, String scientificName, String? family) async {
    String apiKey = await _apiKey(provider);
    String model = (await _userSettingRepository.getOrDefault(
            provider.modelSetting!.key, ""))
        .getOrDefault("")
        .trim();
    if (model.isEmpty) {
      model = provider.defaultModel;
    }

    String prompt = _prompt(scientificName, family);
    Result<String> answer;
    try {
      answer = switch (provider) {
        AiProvider.claude => await _askClaude(apiKey, model, prompt),
        AiProvider.gemini => await _askGemini(apiKey, model, prompt),
        AiProvider.githubModels =>
          await _askGitHubModels(apiKey, model, prompt),
        AiProvider.none => Failure(Exception("No AI provider configured")),
      };
    } catch (e) {
      return Failure(
          Exception("Error while contacting ${provider.displayName}: $e"));
    }
    if (answer.isError()) {
      return Failure(answer.exceptionOrNull()!);
    }
    return parseCare(answer.getOrThrow());
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

  static String _prompt(String scientificName, String? family) {
    String familyText = family == null ? "" : " (family $family)";
    return "Estimate the typical cultivation requirements of the plant "
        "species $scientificName$familyText, as grown at home or in a garden. "
        "Answer only with a JSON object with these integer fields:\n"
        "- light: from 1 (deep shade) to 10 (full direct sun all day)\n"
        "- humidity: ideal ambient relative humidity in percent divided by "
        "10, from 0 to 10\n"
        "- tempMin, tempMax: tolerated temperature range in °C, between -30 "
        "and 50\n"
        "- phMin, phMax: preferred soil pH range, between 0 and 14\n"
        "Use null for any value you do not know with reasonable confidence.";
  }

  static const Map<String, dynamic> _schema = {
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
    },
    'required': fields,
    'additionalProperties': false,
  };

  Future<Result<String>> _askClaude(
      String apiKey, String model, String prompt) async {
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
      'max_tokens': 4096,
      'output_config': {
        'effort': 'low',
        'format': {'type': 'json_schema', 'schema': _schema},
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
}
