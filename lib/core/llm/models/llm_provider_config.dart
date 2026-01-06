import 'package:json_annotation/json_annotation.dart';

part 'llm_provider_config.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LlmProviderConfig {
  final String id;
  final Map<String, dynamic>? httpProxy;
  final Map<String, dynamic>? socksProxy;
  final String? customChatCompletionUrl;
  final String? customListModelsUrl;
  final bool responsesApi;
  final bool supportStream;
  final Map<String, dynamic>? headers;

  LlmProviderConfig({
    required this.id,
    this.httpProxy,
    this.socksProxy,
    this.customChatCompletionUrl,
    this.customListModelsUrl,
    this.responsesApi = false,
    this.supportStream = true,
    this.headers,
  });

  factory LlmProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderConfigToJson(this);
}
