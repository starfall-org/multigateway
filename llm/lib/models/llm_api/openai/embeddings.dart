import 'package:json_annotation/json_annotation.dart';

part 'embeddings.g.dart';

// Request Models
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiEmbeddingsRequest {
  /// Input text to embed, encoded as a string or array of tokens.
  /// To embed multiple inputs, pass an array of strings or array of token arrays.
  final dynamic input;

  /// ID of the model to use (e.g., `text-embedding-ada-002`).
  final String model;

  /// The number of dimensions the resulting output embeddings should have.
  /// Only supported in `text-embedding-3` and later models.
  final int? dimensions;

  /// The format to return the embeddings in. Can be `float` or `base64`.
  final String? encodingFormat;

  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
  final String? user;

  OpenAiEmbeddingsRequest({
    required this.input,
    required this.model,
    this.dimensions,
    this.encodingFormat,
    this.user,
  });

  factory OpenAiEmbeddingsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiEmbeddingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiEmbeddingsRequestToJson(this);
}

// Response Models
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiEmbeddings {
  /// The object type, which is always "list".
  final String object;

  /// A list of embedding objects.
  final List<EmbeddingData> data;

  /// The ID of the model used to generate the embeddings.
  final String model;

  /// Information about the API usage.
  final EmbeddingUsage usage;

  OpenAiEmbeddings({
    required this.object,
    required this.data,
    required this.model,
    required this.usage,
  });

  factory OpenAiEmbeddings.fromJson(Map<String, dynamic> json) =>
      _$OpenAiEmbeddingsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiEmbeddingsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class EmbeddingData {
  /// The object type, which is always "embedding".
  final String object;

  /// The embedding vector, which is a list of floats.
  /// The length of vector depends on the model.
  final List<double> embedding;

  /// The index of the embedding in the list of embeddings.
  final int index;

  EmbeddingData({
    required this.object,
    required this.embedding,
    required this.index,
  });

  factory EmbeddingData.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmbeddingDataToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class EmbeddingUsage {
  /// The number of tokens used for the prompt.
  final int promptTokens;

  /// The total number of tokens used.
  final int totalTokens;

  EmbeddingUsage({required this.promptTokens, required this.totalTokens});

  factory EmbeddingUsage.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingUsageFromJson(json);

  Map<String, dynamic> toJson() => _$EmbeddingUsageToJson(this);
}
