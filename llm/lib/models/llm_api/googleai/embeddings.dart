import 'package:json_annotation/json_annotation.dart';

import 'package:llm/models/llm_api/googleai/generate_content.dart';

part 'embeddings.g.dart';

// Request Models for embeddings endpoint
@JsonSerializable()
class GeminiEmbeddingsRequest {
  final GeminiContent? model;
  final List<String>? content;
  final GeminiEmbeddingTaskType? taskType;

  GeminiEmbeddingsRequest({
    this.model,
    this.content,
    this.taskType,
  });

  factory GeminiEmbeddingsRequest.fromJson(Map<String, dynamic> json) =>
      _$GeminiEmbeddingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiEmbeddingsRequestToJson(this);
}

@JsonSerializable()
class GeminiEmbeddingTaskType {
  final String? type;

  GeminiEmbeddingTaskType({this.type});

  factory GeminiEmbeddingTaskType.fromJson(Map<String, dynamic> json) =>
      _$GeminiEmbeddingTaskTypeFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiEmbeddingTaskTypeToJson(this);
}

@JsonSerializable()
class GeminiEmbeddingContent {
  final List<GeminiPart>? parts;

  GeminiEmbeddingContent({this.parts});

  factory GeminiEmbeddingContent.fromJson(Map<String, dynamic> json) =>
      _$GeminiEmbeddingContentFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiEmbeddingContentToJson(this);
}

// Response Models for embeddings endpoint
@JsonSerializable()
class GeminiEmbeddingsResponse {
  final GeminiEmbeddingValue? embedding;

  GeminiEmbeddingsResponse({this.embedding});

  factory GeminiEmbeddingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiEmbeddingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiEmbeddingsResponseToJson(this);
}

@JsonSerializable()
class GeminiEmbeddingValue {
  final List<double>? values;

  GeminiEmbeddingValue({this.values});

  factory GeminiEmbeddingValue.fromJson(Map<String, dynamic> json) =>
      _$GeminiEmbeddingValueFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiEmbeddingValueToJson(this);
}

// Batch Embeddings Request
@JsonSerializable()
class GeminiBatchEmbeddingsRequest {
  final GeminiContent? model;
  final List<GeminiEmbeddingContent>? requests;
  final GeminiEmbeddingTaskType? taskType;

  GeminiBatchEmbeddingsRequest({
    this.model,
    this.requests,
    this.taskType,
  });

  factory GeminiBatchEmbeddingsRequest.fromJson(Map<String, dynamic> json) =>
      _$GeminiBatchEmbeddingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiBatchEmbeddingsRequestToJson(this);
}

// Batch Embeddings Response
@JsonSerializable()
class GeminiBatchEmbeddingsResponse {
  final List<GeminiEmbeddingValue>? embeddings;

  GeminiBatchEmbeddingsResponse({this.embeddings});

  factory GeminiBatchEmbeddingsResponse.fromJson(Map<String, dynamic> json) =>
      _$GeminiBatchEmbeddingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiBatchEmbeddingsResponseToJson(this);
}