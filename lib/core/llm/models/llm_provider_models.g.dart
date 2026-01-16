// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmProviderModels _$LlmProviderModelsFromJson(Map<String, dynamic> json) =>
    LlmProviderModels(
      id: json['id'] as String,
      models: (json['models'] as List<dynamic>)
          .map((e) =>
              e == null ? null : LlmModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LlmProviderModelsToJson(LlmProviderModels instance) =>
    <String, dynamic>{
      'id': instance.id,
      'models': instance.models.map((e) => e?.toJson()).toList(),
    };

LlmModel _$LlmModelFromJson(Map<String, dynamic> json) => LlmModel(
      id: json['id'] as String,
      icon: json['icon'] as String?,
      displayName: json['display_name'] as String,
      type: $enumDecode(_$LlmModelTypeEnumMap, json['type']),
      origin: json['origin'],
      originType:
          $enumDecodeNullable(_$OriginModelTypeEnumMap, json['origin_type']),
      originData: json['origin_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LlmModelToJson(LlmModel instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'display_name': instance.displayName,
      'type': _$LlmModelTypeEnumMap[instance.type]!,
      'origin_type': _$OriginModelTypeEnumMap[instance.originType],
      'origin_data': instance.originData,
      'origin': instance.origin,
    };

const _$LlmModelTypeEnumMap = {
  LlmModelType.chat: 'chat',
  LlmModelType.image: 'image',
  LlmModelType.audio: 'audio',
  LlmModelType.video: 'video',
  LlmModelType.embed: 'embed',
};

const _$OriginModelTypeEnumMap = {
  OriginModelType.basic: 'basic',
  OriginModelType.github: 'github',
  OriginModelType.googleai: 'googleai',
  OriginModelType.ollama: 'ollama',
};
