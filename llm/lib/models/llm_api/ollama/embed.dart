import 'package:json_annotation/json_annotation.dart';

part 'embed.g.dart';

/// Request model for Ollama /api/embed endpoint
@JsonSerializable()
class OllamaEmbedRequest {
  final String model;
  final String input;
  final OllamaEmbedOptions? options;

  OllamaEmbedRequest({
    required this.model,
    required this.input,
    this.options,
  });

  factory OllamaEmbedRequest.fromJson(Map<String, dynamic> json) =>
      _$OllamaEmbedRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaEmbedRequestToJson(this);
}

/// Options for embedding generation
@JsonSerializable()
class OllamaEmbedOptions {
  final int? numCtx;
  final int? numBatch;
  final int? numGqa;
  final int? numGpu;
  final int? numThread;
  final int? seed;
  final bool? useMmap;
  final bool? useMlock;
  final int? f16Kv;
  final int? logitsAll;
  final int? vocabOnly;
  final bool? ropeFrequencyBase;
  final bool? ropeFrequencyScale;
  final int? numPredict;

  OllamaEmbedOptions({
    this.numCtx,
    this.numBatch,
    this.numGqa,
    this.numGpu,
    this.numThread,
    this.seed,
    this.useMmap,
    this.useMlock,
    this.f16Kv,
    this.logitsAll,
    this.vocabOnly,
    this.ropeFrequencyBase,
    this.ropeFrequencyScale,
    this.numPredict,
  });

  factory OllamaEmbedOptions.fromJson(Map<String, dynamic> json) =>
      _$OllamaEmbedOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaEmbedOptionsToJson(this);
}

/// Response model for Ollama /api/embed endpoint
@JsonSerializable()
class OllamaEmbedResponse {
  final String model;
  final List<double> embedding;

  OllamaEmbedResponse({
    required this.model,
    required this.embedding,
  });

  factory OllamaEmbedResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaEmbedResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaEmbedResponseToJson(this);
}