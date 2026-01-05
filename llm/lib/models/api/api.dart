import 'package:json_annotation/json_annotation.dart';

part 'api.g.dart';

enum AIContentType { text, image, audio, video }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AIContent {
  final AIContentType type;
  final String? text;
  final String? uri;
  final String? filePath;
  final String? mimeType;
  final String? dataBase64;

  const AIContent({
    required this.type,
    this.text,
    this.uri,
    this.filePath,
    this.mimeType,
    this.dataBase64,
  });

  factory AIContent.fromJson(Map<String, dynamic> json) =>
      _$AIContentFromJson(json);

  Map<String, dynamic> toJson() => _$AIContentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AIToolFunction {
  final String name;
  final String? description;
  final Map<String, dynamic> parameters;

  const AIToolFunction({
    required this.name,
    this.description,
    this.parameters = const {},
  });

  factory AIToolFunction.fromJson(Map<String, dynamic> json) =>
      _$AIToolFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$AIToolFunctionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AIToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  const AIToolCall({
    required this.id,
    required this.name,
    this.arguments = const {},
  });

  factory AIToolCall.fromJson(Map<String, dynamic> json) =>
      _$AIToolCallFromJson(json);

  Map<String, dynamic> toJson() => _$AIToolCallToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AIMessage {
  final String role;
  final List<AIContent> content;
  final String? name;
  final String? toolCallId;

  const AIMessage({
    required this.role,
    required this.content,
    this.name,
    this.toolCallId,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AIMessageToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AIRequest {
  final String model;
  final List<AIMessage> messages;
  final List<AIToolFunction> tools;
  final String? toolChoice;
  final List<AIContent> images;
  final List<AIContent> audios;
  final List<AIContent> files;
  final double? temperature;
  final int? maxTokens;
  final bool stream;
  final Map<String, dynamic> extra;

  const AIRequest({
    required this.model,
    required this.messages,
    this.tools = const [],
    this.toolChoice,
    this.images = const [],
    this.audios = const [],
    this.files = const [],
    this.temperature,
    this.maxTokens,
    this.stream = false,
    this.extra = const {},
  });

  factory AIRequest.fromJson(Map<String, dynamic> json) =>
      _$AIRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AIRequestToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AIResponse {
  final String text;
  final List<AIToolCall> toolCalls;
  final String? finishReason;
  final List<AIContent> contents;
  final String? reasoningContent;
  final Map<String, dynamic> raw;

  const AIResponse({
    required this.text,
    this.toolCalls = const [],
    this.finishReason,
    this.contents = const [],
    this.reasoningContent,
    this.raw = const {},
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIResponseToJson(this);

  AIResponse copyWith({
    String? text,
    List<AIToolCall>? toolCalls,
    String? finishReason,
    List<AIContent>? contents,
    String? reasoningContent,
    Map<String, dynamic>? raw,
  }) {
    return AIResponse(
      text: text ?? this.text,
      toolCalls: toolCalls ?? this.toolCalls,
      finishReason: finishReason ?? this.finishReason,
      contents: contents ?? this.contents,
      reasoningContent: reasoningContent ?? this.reasoningContent,
      raw: raw ?? this.raw,
    );
  }
}

abstract class AIBaseApi {
  Future<AIResponse> generate(AIRequest request);
  Stream<AIResponse> generateStream(AIRequest request);
}
