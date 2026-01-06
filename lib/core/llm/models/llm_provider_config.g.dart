// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmProviderConfig _$LlmProviderConfigFromJson(Map<String, dynamic> json) =>
    LlmProviderConfig(
      id: json['id'] as String,
      httpProxy: json['http_proxy'] as Map<String, dynamic>?,
      socksProxy: json['socks_proxy'] as Map<String, dynamic>?,
      customChatCompletionUrl: json['custom_chat_completion_url'] as String?,
      customListModelsUrl: json['custom_list_models_url'] as String?,
      responsesApi: json['responses_api'] as bool? ?? false,
      supportStream: json['support_stream'] as bool? ?? true,
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LlmProviderConfigToJson(LlmProviderConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'http_proxy': instance.httpProxy,
      'socks_proxy': instance.socksProxy,
      'custom_chat_completion_url': instance.customChatCompletionUrl,
      'custom_list_models_url': instance.customListModelsUrl,
      'responses_api': instance.responsesApi,
      'support_stream': instance.supportStream,
      'headers': instance.headers,
    };
