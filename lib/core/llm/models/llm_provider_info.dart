import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'llm_provider_info.g.dart';

enum ProviderType {
  openai("OpenAI"),
  google('Google'),
  anthropic("Anthropic"),
  ollama("Ollama");

  final String name;

  const ProviderType(this.name);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmProviderInfo {
  final String id;
  final String name;
  final ProviderType type;
  final Authorization auth;
  final String? icon;
  final String baseUrl;
  final Configuration config;

  LlmProviderInfo({
    String? id,
    String? name,
    required this.type,
    Authorization? auth,
    this.icon,
    String? baseUrl,
    required this.config,
  }) : id = id ?? Uuid().v4(),
       name = name ?? _defaultName(type),
       auth = auth ?? Authorization(method: AuthMethod.other),
       baseUrl = baseUrl ?? _defaultBaseUrl(type);

  static String _defaultName(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'OpenAI';
      case ProviderType.anthropic:
        return 'Anthropic';
      case ProviderType.ollama:
        return 'Ollama';
      case ProviderType.google:
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
      case ProviderType.google:
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
    return 'LlmProviderInfo{id: $id, name: $name, type: $type, auth: $auth, icon: $icon, baseUrl: $baseUrl}';
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Authorization {
  final AuthMethod method;
  final String? key;
  final String? value;

  Authorization({required this.method, this.key, this.value});

  factory Authorization.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizationToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Configuration {
  final Map<String, dynamic> httpProxy;
  final Map<String, dynamic> socksProxy;
  final bool supportStream;
  final Map<String, dynamic> headers;
  final bool responsesApi;
  final String? customListModelsUrl;

  Configuration({
    required this.httpProxy,
    required this.socksProxy,
    this.supportStream = true,
    required this.headers,
    this.responsesApi = false,
    this.customListModelsUrl,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurationToJson(this);
}

enum AuthMethod { queryParam, bearerToken, customHeader, other }
