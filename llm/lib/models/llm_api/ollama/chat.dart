import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

/// Request model for Ollama /api/chat endpoint
@JsonSerializable()
class OllamaChatRequest {
  final String model;
  final List<OllamaMessage> messages;
  final String? format;
  final OllamaOptions? options;
  final bool? stream;
  final List<OllamaTool>? tools;

  OllamaChatRequest({
    required this.model,
    required this.messages,
    this.format,
    this.options,
    this.stream,
    this.tools,
  });

  factory OllamaChatRequest.fromJson(Map<String, dynamic> json) =>
      _$OllamaChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaChatRequestToJson(this);
}

/// Message in Ollama chat
@JsonSerializable()
class OllamaMessage {
  final String role;
  final dynamic content;
  final List<OllamaImage>? images;
  final OllamaToolCall? toolCalls;

  OllamaMessage({
    required this.role,
    required this.content,
    this.images,
    this.toolCalls,
  });

  factory OllamaMessage.fromJson(Map<String, dynamic> json) =>
      _$OllamaMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaMessageToJson(this);
}

/// Image content in message
@JsonSerializable()
class OllamaImage {
  final String data;

  OllamaImage({required this.data});

  factory OllamaImage.fromJson(Map<String, dynamic> json) =>
      _$OllamaImageFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaImageToJson(this);
}

/// Tool definition for Ollama
@JsonSerializable()
class OllamaTool {
  final OllamaFunction function;
  final String type;

  OllamaTool({
    required this.function,
    this.type = 'function',
  });

  factory OllamaTool.fromJson(Map<String, dynamic> json) =>
      _$OllamaToolFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaToolToJson(this);
}

/// Function definition
@JsonSerializable()
class OllamaFunction {
  final String name;
  final String? description;
  final Map<String, dynamic>? parameters;

  OllamaFunction({
    required this.name,
    this.description,
    this.parameters,
  });

  factory OllamaFunction.fromJson(Map<String, dynamic> json) =>
      _$OllamaFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaFunctionToJson(this);
}

/// Tool call in message
@JsonSerializable()
class OllamaToolCall {
  final OllamaToolCallFunction function;

  OllamaToolCall({required this.function});

  factory OllamaToolCall.fromJson(Map<String, dynamic> json) =>
      _$OllamaToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaToolCallToJson(this);
}

/// Function call details
@JsonSerializable()
class OllamaToolCallFunction {
  final String name;
  final Map<String, dynamic> arguments;

  OllamaToolCallFunction({
    required this.name,
    required this.arguments,
  });

  factory OllamaToolCallFunction.fromJson(Map<String, dynamic> json) =>
      _$OllamaToolCallFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaToolCallFunctionToJson(this);
}

/// Options for Ollama generation
@JsonSerializable()
class OllamaOptions {
  final int? numCtx;
  final int? numBatch;
  final double? temperature;
  final int? topK;
  final double? topP;
  final int? numGqa;
  final int? numGpu;
  final int? numThread;
  final int? seed;
  final bool? useMmap;
  final bool? useMlock;
  final double? repeatLastN;
  final double? repeatPenalty;
  final double? presencePenalty;
  final double? frequencyPenalty;
  final double? dryMultiplier;
  final double? dryBase;
  final int? dryAllowedLength;
  final List<String>? drySpecialTokens;
  final int? numPredict;
  final int? stop;
  final List<int>? tfsZ;
  final int? typicalP;
  final int? penaltyLastN;
  final int? mirostat;
  final double? mirostatTau;
  final double? mirostatEta;
  final int? penalizeNewline;

  OllamaOptions({
    this.numCtx,
    this.numBatch,
    this.temperature,
    this.topK,
    this.topP,
    this.numGqa,
    this.numGpu,
    this.numThread,
    this.seed,
    this.useMmap,
    this.useMlock,
    this.repeatLastN,
    this.repeatPenalty,
    this.presencePenalty,
    this.frequencyPenalty,
    this.dryMultiplier,
    this.dryBase,
    this.dryAllowedLength,
    this.drySpecialTokens,
    this.numPredict,
    this.stop,
    this.tfsZ,
    this.typicalP,
    this.penaltyLastN,
    this.mirostat,
    this.mirostatTau,
    this.mirostatEta,
    this.penalizeNewline,
  });

  factory OllamaOptions.fromJson(Map<String, dynamic> json) =>
      _$OllamaOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaOptionsToJson(this);
}

/// Response model for Ollama /api/chat endpoint (non-streaming)
@JsonSerializable()
class OllamaChatResponse {
  final String model;
  final String createdAt;
  final OllamaMessage message;
  final bool done;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? promptEvalDuration;
  final int? evalCount;
  final int? evalDuration;

  OllamaChatResponse({
    required this.model,
    required this.createdAt,
    required this.message,
    required this.done,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
  });

  factory OllamaChatResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaChatResponseToJson(this);
}

/// Response model for Ollama /api/chat endpoint (streaming)
@JsonSerializable()
class OllamaChatStreamResponse {
  final String? model;
  final String? createdAt;
  final OllamaMessage? message;
  final bool? done;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? promptEvalDuration;
  final int? evalCount;
  final int? evalDuration;

  OllamaChatStreamResponse({
    this.model,
    this.createdAt,
    this.message,
    this.done,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
  });

  factory OllamaChatStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaChatStreamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaChatStreamResponseToJson(this);
}