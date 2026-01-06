// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmProviderConfig _$LlmProviderConfigFromJson(Map<String, dynamic> json) =>
    LlmProviderConfig(
      providerId: json['provider_id'] as String,
      httpProxy: json['http_proxy'] as Map<String, dynamic>?,
      socksProxy: json['socks_proxy'] as Map<String, dynamic>?,
      customChatCompletionUrl: json['custom_chat_completion_url'] as String?,
      customListModelsUrl: json['custom_list_models_url'] as String?,
      headers: json['headers'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LlmProviderConfigToJson(LlmProviderConfig instance) =>
    <String, dynamic>{
      'provider_id': instance.providerId,
      'http_proxy': instance.httpProxy,
      'socks_proxy': instance.socksProxy,
      'custom_chat_completion_url': instance.customChatCompletionUrl,
      'custom_list_models_url': instance.customListModelsUrl,
      'headers': instance.headers,
    };
