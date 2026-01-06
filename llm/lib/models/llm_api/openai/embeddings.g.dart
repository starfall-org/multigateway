// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embeddings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiEmbeddingsRequest _$OpenAiEmbeddingsRequestFromJson(
  Map<String, dynamic> json,
) => OpenAiEmbeddingsRequest(
  input: json['input'],
  model: json['model'] as String,
  dimensions: (json['dimensions'] as num?)?.toInt(),
  encodingFormat: json['encoding_format'] as String?,
  user: json['user'] as String?,
);

Map<String, dynamic> _$OpenAiEmbeddingsRequestToJson(
  OpenAiEmbeddingsRequest instance,
) => <String, dynamic>{
  'input': instance.input,
  'model': instance.model,
  'dimensions': instance.dimensions,
  'encoding_format': instance.encodingFormat,
  'user': instance.user,
};

OpenAiEmbeddings _$OpenAiEmbeddingsFromJson(Map<String, dynamic> json) =>
    OpenAiEmbeddings(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => EmbeddingData.fromJson(e as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String,
      usage: EmbeddingUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAiEmbeddingsToJson(OpenAiEmbeddings instance) =>
    <String, dynamic>{
      'object': instance.object,
      'data': instance.data.map((e) => e.toJson()).toList(),
      'model': instance.model,
      'usage': instance.usage.toJson(),
    };

EmbeddingData _$EmbeddingDataFromJson(Map<String, dynamic> json) =>
    EmbeddingData(
      object: json['object'] as String,
      embedding: (json['embedding'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      index: (json['index'] as num).toInt(),
    );

Map<String, dynamic> _$EmbeddingDataToJson(EmbeddingData instance) =>
    <String, dynamic>{
      'object': instance.object,
      'embedding': instance.embedding,
      'index': instance.index,
    };

EmbeddingUsage _$EmbeddingUsageFromJson(Map<String, dynamic> json) =>
    EmbeddingUsage(
      promptTokens: (json['prompt_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$EmbeddingUsageToJson(EmbeddingUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'total_tokens': instance.totalTokens,
    };
