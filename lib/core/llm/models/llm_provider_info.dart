import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'llm_provider_info.g.dart';

enum ProviderType {
  openai("OpenAI"),
  googleai('AI Studio'),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

enum AuthMethod { queryParam, bearerToken, customHeader, other }

@JsonSerializable(fieldRename: FieldRename.snake)
class LlmProviderInfo {
  final String id;
  final String name;
  final ProviderType type;
  final Authorization auth;
  final String? icon;
  final String baseUrl;

  LlmProviderInfo({
    String? id,
    String? name,
    required this.type,
    Authorization? auth,
    this.icon,
    String? baseUrl,
  }) : id = id ?? Uuid().v4(),
       name = name ?? _defaultName(type),
       auth = auth ?? Authorization(type: AuthMethod.other),
       baseUrl = baseUrl ?? _defaultBaseUrl(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.googleai:
        return 'Google';
    }
  }

  static String _defaultBaseUrl(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'https://api.openai.com/v1';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'https://ollama.com/api';
      case ProviderType.googleai:
        return 'https://generativelanguage.googleapis.com/v1beta';
    }
  }

  Map<String, dynamic> toJson() => _$LlmProviderInfoToJson(this);

  factory LlmProviderInfo.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderInfoFromJson(json);

  String toJsonString() => json.encode(toJson());

  factory LlmProviderInfo.fromJsonString(String jsonString) =>
      LlmProviderInfo.fromJson(json.decode(jsonString));

  @override
  String toString() {
    return 'LlmProviderInfo{id: $id, name: $name, type: $type, apiKey: $apiKey, icon: $icon, baseUrl: $baseUrl}';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Authorization {
  final AuthMethod type;
  final String? key;
  final String? valuePrefix;
  final String? otherArgs;

  Authorization({
    required this.type,
    this.key,
    this.valuePrefix,
    this.otherArgs,
  });

  factory Authorization.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizationToJson(this);
}
