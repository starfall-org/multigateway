// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'default_options.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefaultOptions _$DefaultOptionsFromJson(Map<String, dynamic> json) =>
    DefaultOptions(
      defaultModels: DefaultModels.fromJson(
          json['default_models'] as Map<String, dynamic>),
      defaultProfileId: json['default_profile_id'] as String,
    );

Map<String, dynamic> _$DefaultOptionsToJson(DefaultOptions instance) =>
    <String, dynamic>{
      'default_models': instance.defaultModels.toJson(),
      'default_profile_id': instance.defaultProfileId,
    };

DefaultModels _$DefaultModelsFromJson(Map<String, dynamic> json) =>
    DefaultModels(
      titleGenerationModel: json['title_generation_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['title_generation_model'] as Map<String, dynamic>),
      chatSummarizationModel: json['chat_summarization_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['chat_summarization_model'] as Map<String, dynamic>),
      translationModel: json['translation_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['translation_model'] as Map<String, dynamic>),
      supportOcrModel: json['support_ocr_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['support_ocr_model'] as Map<String, dynamic>),
      embeddingModel: json['embedding_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['embedding_model'] as Map<String, dynamic>),
      imageGenerationModel: json['image_generation_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['image_generation_model'] as Map<String, dynamic>),
      chatModel: json['chat_model'] == null
          ? null
          : DefaultModel.fromJson(json['chat_model'] as Map<String, dynamic>),
      audioGenerationModel: json['audio_generation_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['audio_generation_model'] as Map<String, dynamic>),
      videoGenerationModel: json['video_generation_model'] == null
          ? null
          : DefaultModel.fromJson(
              json['video_generation_model'] as Map<String, dynamic>),
      rerankModel: json['rerank_model'] == null
          ? null
          : DefaultModel.fromJson(json['rerank_model'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DefaultModelsToJson(DefaultModels instance) =>
    <String, dynamic>{
      'title_generation_model': instance.titleGenerationModel?.toJson(),
      'chat_summarization_model': instance.chatSummarizationModel?.toJson(),
      'translation_model': instance.translationModel?.toJson(),
      'support_ocr_model': instance.supportOcrModel?.toJson(),
      'embedding_model': instance.embeddingModel?.toJson(),
      'image_generation_model': instance.imageGenerationModel?.toJson(),
      'chat_model': instance.chatModel?.toJson(),
      'audio_generation_model': instance.audioGenerationModel?.toJson(),
      'video_generation_model': instance.videoGenerationModel?.toJson(),
      'rerank_model': instance.rerankModel?.toJson(),
    };

DefaultModel _$DefaultModelFromJson(Map<String, dynamic> json) => DefaultModel(
      modelName: json['model_name'] as String,
      providerId: json['provider_id'] as String,
    );

Map<String, dynamic> _$DefaultModelToJson(DefaultModel instance) =>
    <String, dynamic>{
      'model_name': instance.modelName,
      'provider_id': instance.providerId,
    };
