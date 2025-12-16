import 'dart:convert';
import 'ai_model.dart';

enum ProviderType { googleGenAI, openAI, anthropic, ollama }

class Provider {
  final String name;
  final ProviderType type;
  final String? apiKey;
  final String? logoUrl;
  final String? baseUrl;
  final Map<String, String> headers;
  final List<ModelInfo> models;

  Provider({
    required this.type,
    String? name,
    this.apiKey,
    this.logoUrl,
    String? baseUrl,
    this.headers = const {},
    this.models = const [],
  }) : baseUrl = baseUrl ?? _defaultBaseUrl(type),
       name = name ?? _defaultName(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openAI:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.googleGenAI:
        return 'Google Generative AI';
    }
  }

  static String? _defaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openAI:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'https://ollama.com';
      case ProviderType.googleGenAI:
        return 'https://generativelanguage.googleapis.com/v1beta';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'logoUrl': logoUrl,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'headers': headers,
      'models': models.map((m) => m.toJson()).toList(),
    };
  }

  factory Provider.fromJson(Map<String, dynamic> json) {
    var modelsJson = json['models'];
    List<ModelInfo> parsedModels = [];

    if (modelsJson != null) {
      if (modelsJson is List &&
          modelsJson.isNotEmpty &&
          modelsJson.first is String) {
        parsedModels = modelsJson
            .map((e) => ModelInfo(name: e as String))
            .toList();
      } else {
        parsedModels = (modelsJson as List)
            .map((e) => ModelInfo.fromJson(e))
            .toList();
      }
    }

    return Provider(
      type: ProviderType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      baseUrl: json['baseUrl'] as String?,
      headers: Map<String, String>.from(json['headers'] ?? {}),
      models: parsedModels,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Provider.fromJsonString(String jsonString) =>
      Provider.fromJson(json.decode(jsonString));
}
