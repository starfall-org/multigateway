import 'package:json_annotation/json_annotation.dart';

part 'messages.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicMessagesRequest {
  final String model;
  final List<AnthropicMessage> messages;
  final int maxTokens;
  final String? system;
  final double? temperature;
  final List<AnthropicTool>? tools;
  final dynamic toolChoice;
  final bool? stream;

  AnthropicMessagesRequest({
    required this.model,
    required this.messages,
    required this.maxTokens,
    this.system,
    this.temperature,
    this.tools,
    this.toolChoice,
    this.stream,
  });

  factory AnthropicMessagesRequest.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessagesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessagesRequestToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicMessage {
  final String role;
  final dynamic content; // String or List<AnthropicContent>

  AnthropicMessage({required this.role, required this.content});

  factory AnthropicMessage.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessageFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessageToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicContent {
  final String type;
  final String? text;
  final String? source;
  final String? mediaType;
  final String? data;

  AnthropicContent({
    required this.type,
    this.text,
    this.source,
    this.mediaType,
    this.data,
  });

  factory AnthropicContent.fromJson(Map<String, dynamic> json) =>
      _$AnthropicContentFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicContentToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicTool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  AnthropicTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  factory AnthropicTool.fromJson(Map<String, dynamic> json) =>
      _$AnthropicToolFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicToolToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicMessagesResponse {
  final String id;
  final String type;
  final String role;
  final List<AnthropicContent> content;
  final String model;
  final String? stopReason;
  final String? stopSequence;
  final AnthropicUsage usage;

  AnthropicMessagesResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    this.stopReason,
    this.stopSequence,
    required this.usage,
  });

  factory AnthropicMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$AnthropicMessagesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicMessagesResponseToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicUsage {
  final int inputTokens;
  final int outputTokens;

  AnthropicUsage({required this.inputTokens, required this.outputTokens});

  factory AnthropicUsage.fromJson(Map<String, dynamic> json) =>
      _$AnthropicUsageFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicUsageToJson(this);
}
