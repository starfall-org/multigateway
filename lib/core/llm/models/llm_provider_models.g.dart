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
      displayName: json['display_name'] as String,
      icon: json['icon'] as String?,
      providerId: json['provider_id'] as String,
      inputCapabilities: Capabilities.fromJson(
          json['input_capabilities'] as Map<String, dynamic>),
      outputCapabilities: Capabilities.fromJson(
          json['output_capabilities'] as Map<String, dynamic>),
      modelInfo: json['model_info'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LlmModelToJson(LlmModel instance) => <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'icon': instance.icon,
      'provider_id': instance.providerId,
      'input_capabilities': instance.inputCapabilities.toJson(),
      'output_capabilities': instance.outputCapabilities.toJson(),
      'model_info': instance.modelInfo,
    };

Capabilities _$CapabilitiesFromJson(Map<String, dynamic> json) => Capabilities(
      text: json['text'] as bool? ?? true,
      image: json['image'] as bool? ?? false,
      video: json['video'] as bool? ?? false,
      embed: json['embed'] as bool? ?? false,
      audio: json['audio'] as bool? ?? false,
      others: json['others'] as String?,
    );

Map<String, dynamic> _$CapabilitiesToJson(Capabilities instance) =>
    <String, dynamic>{
      'text': instance.text,
      'image': instance.image,
      'video': instance.video,
      'embed': instance.embed,
      'audio': instance.audio,
      'others': instance.others,
    };
