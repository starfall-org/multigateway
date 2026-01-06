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
    );

Map<String, dynamic> _$LlmProviderInfoToJson(LlmProviderInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ProviderTypeEnumMap[instance.type]!,
      'auth': instance.auth.toJson(),
      'icon': instance.icon,
      'base_url': instance.baseUrl,
    };

const _$ProviderTypeEnumMap = {
  ProviderType.openai: 'openai',
  ProviderType.googleai: 'googleai',
  ProviderType.anthropic: 'anthropic',
  ProviderType.ollama: 'ollama',
};

Authorization _$AuthorizationFromJson(Map<String, dynamic> json) =>
    Authorization(
      type: $enumDecode(_$AuthMethodEnumMap, json['type']),
      key: json['key'] as String?,
      valuePrefix: json['value_prefix'] as String?,
      otherArgs: json['other_args'] as String?,
    );

Map<String, dynamic> _$AuthorizationToJson(Authorization instance) =>
    <String, dynamic>{
      'type': _$AuthMethodEnumMap[instance.type]!,
      'key': instance.key,
      'value_prefix': instance.valuePrefix,
      'other_args': instance.otherArgs,
    };

const _$AuthMethodEnumMap = {
  AuthMethod.queryParam: 'queryParam',
  AuthMethod.bearerToken: 'bearerToken',
  AuthMethod.customHeader: 'customHeader',
  AuthMethod.other: 'other',
};
