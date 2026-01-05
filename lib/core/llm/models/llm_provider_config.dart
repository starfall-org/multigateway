import 'package:json_annotation/json_annotation.dart';

part 'llm_provider_config.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LlmProviderConfig {
  final String providerId;
  final Map<String, dynamic> httpProxy;
  final String? customChatCompletionUrl;
  final String? customListModelsUrl;

  LlmProviderConfig({
    required this.providerId,
    required this.httpProxy,
    this.customChatCompletionUrl,
    this.customListModelsUrl,
  });

  factory LlmProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderConfigToJson(this);
}
