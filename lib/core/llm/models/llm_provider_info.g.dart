// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmProviderInfo _$LlmProviderInfoFromJson(Map<String, dynamic> json) =>
    LlmProviderInfo(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: $enumDecode(_$ProviderTypeEnumMap, json['type']),
      auth: json['auth'] == null
          ? null
          : Authorization.fromJson(json['auth'] as Map<String, dynamic>),
      icon: json['icon'] as String?,
      baseUrl: json['base_url'] as String?,
      config: Configuration.fromJson(json['config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LlmProviderInfoToJson(LlmProviderInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ProviderTypeEnumMap[instance.type]!,
      'auth': instance.auth.toJson(),
      'icon': instance.icon,
      'base_url': instance.baseUrl,
      'config': instance.config.toJson(),
    };

const _$ProviderTypeEnumMap = {
  ProviderType.openai: 'openai',
  ProviderType.google: 'google',
  ProviderType.anthropic: 'anthropic',
  ProviderType.ollama: 'ollama',
};

Authorization _$AuthorizationFromJson(Map<String, dynamic> json) =>
    Authorization(
      method: $enumDecode(_$AuthMethodEnumMap, json['method']),
      key: json['key'] as String?,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$AuthorizationToJson(Authorization instance) =>
    <String, dynamic>{
      'method': _$AuthMethodEnumMap[instance.method]!,
      'key': instance.key,
      'value': instance.value,
    };

const _$AuthMethodEnumMap = {
  AuthMethod.queryParam: 'queryParam',
  AuthMethod.bearerToken: 'bearerToken',
  AuthMethod.customHeader: 'customHeader',
  AuthMethod.other: 'other',
};

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) =>
    Configuration(
      httpProxy: json['http_proxy'] as Map<String, dynamic>,
      socksProxy: json['socks_proxy'] as Map<String, dynamic>,
      supportStream: json['support_stream'] as bool? ?? true,
      headers: json['headers'] as Map<String, dynamic>,
      responsesApi: json['responses_api'] as bool? ?? false,
      customListModelsUrl: json['custom_list_models_url'] as String?,
    );

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{
      'http_proxy': instance.httpProxy,
      'socks_proxy': instance.socksProxy,
      'support_stream': instance.supportStream,
      'headers': instance.headers,
      'responses_api': instance.responsesApi,
      'custom_list_models_url': instance.customListModelsUrl,
    };
