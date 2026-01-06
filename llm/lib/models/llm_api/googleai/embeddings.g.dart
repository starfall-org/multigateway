// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embeddings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeminiEmbeddingsRequest _$GeminiEmbeddingsRequestFromJson(
  Map<String, dynamic> json,
) => GeminiEmbeddingsRequest(
  model: json['model'] == null
      ? null
      : GeminiContent.fromJson(json['model'] as Map<String, dynamic>),
  content: (json['content'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  taskType: json['taskType'] == null
      ? null
      : GeminiEmbeddingTaskType.fromJson(
          json['taskType'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiEmbeddingsRequestToJson(
  GeminiEmbeddingsRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'content': instance.content,
  'taskType': instance.taskType,
};

GeminiEmbeddingTaskType _$GeminiEmbeddingTaskTypeFromJson(
  Map<String, dynamic> json,
) => GeminiEmbeddingTaskType(type: json['type'] as String?);

Map<String, dynamic> _$GeminiEmbeddingTaskTypeToJson(
  GeminiEmbeddingTaskType instance,
) => <String, dynamic>{'type': instance.type};

GeminiEmbeddingContent _$GeminiEmbeddingContentFromJson(
  Map<String, dynamic> json,
) => GeminiEmbeddingContent(
  parts: (json['parts'] as List<dynamic>?)
      ?.map((e) => GeminiPart.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiEmbeddingContentToJson(
  GeminiEmbeddingContent instance,
) => <String, dynamic>{'parts': instance.parts};

GeminiEmbeddingsResponse _$GeminiEmbeddingsResponseFromJson(
  Map<String, dynamic> json,
) => GeminiEmbeddingsResponse(
  embedding: json['embedding'] == null
      ? null
      : GeminiEmbeddingValue.fromJson(
          json['embedding'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiEmbeddingsResponseToJson(
  GeminiEmbeddingsResponse instance,
) => <String, dynamic>{'embedding': instance.embedding};

GeminiEmbeddingValue _$GeminiEmbeddingValueFromJson(
  Map<String, dynamic> json,
) => GeminiEmbeddingValue(
  values: (json['values'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$GeminiEmbeddingValueToJson(
  GeminiEmbeddingValue instance,
) => <String, dynamic>{'values': instance.values};

GeminiBatchEmbeddingsRequest _$GeminiBatchEmbeddingsRequestFromJson(
  Map<String, dynamic> json,
) => GeminiBatchEmbeddingsRequest(
  model: json['model'] == null
      ? null
      : GeminiContent.fromJson(json['model'] as Map<String, dynamic>),
  requests: (json['requests'] as List<dynamic>?)
      ?.map((e) => GeminiEmbeddingContent.fromJson(e as Map<String, dynamic>))
      .toList(),
  taskType: json['taskType'] == null
      ? null
      : GeminiEmbeddingTaskType.fromJson(
          json['taskType'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$GeminiBatchEmbeddingsRequestToJson(
  GeminiBatchEmbeddingsRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'requests': instance.requests,
  'taskType': instance.taskType,
};

GeminiBatchEmbeddingsResponse _$GeminiBatchEmbeddingsResponseFromJson(
  Map<String, dynamic> json,
) => GeminiBatchEmbeddingsResponse(
  embeddings: (json['embeddings'] as List<dynamic>?)
      ?.map((e) => GeminiEmbeddingValue.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GeminiBatchEmbeddingsResponseToJson(
  GeminiBatchEmbeddingsResponse instance,
) => <String, dynamic>{'embeddings': instance.embeddings};
