// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LlmProviderModels _$LlmProviderModelsFromJson(Map<String, dynamic> json) =>
    LlmProviderModels(
      providerId: json['providerId'] as String,
      basicModels: (json['basicModels'] as List<dynamic>)
          .map((e) =>
              e == null ? null : BasicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ollamaModels: (json['ollamaModels'] as List<dynamic>)
          .map((e) => e == null
              ? null
              : OllamaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      googleAiModels: (json['googleAiModels'] as List<dynamic>)
          .map((e) => e == null
              ? null
              : GoogleAiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      githubModels: (json['githubModels'] as List<dynamic>)
          .map((e) => e == null
              ? null
              : GitHubModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LlmProviderModelsToJson(LlmProviderModels instance) =>
    <String, dynamic>{
      'providerId': instance.providerId,
      'basicModels': instance.basicModels,
      'ollamaModels': instance.ollamaModels,
      'googleAiModels': instance.googleAiModels,
      'githubModels': instance.githubModels,
    };
