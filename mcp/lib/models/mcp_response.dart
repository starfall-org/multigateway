import 'package:json_annotation/json_annotation.dart';

import 'mcp_core.dart';

part 'mcp_response.g.dart';

/// Response result for 'initialize' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class InitializeResult {
  final String protocolVersion;
  final McpServerCapabilities capabilities;
  final McpImplementation serverInfo;

  InitializeResult({
    required this.protocolVersion,
    required this.capabilities,
    required this.serverInfo,
  });

  factory InitializeResult.fromJson(Map<String, dynamic> json) =>
      _$InitializeResultFromJson(json);
  Map<String, dynamic> toJson() => _$InitializeResultToJson(this);
}

/// Response result for 'tools/list' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ListToolsResult {
  final List<McpTool> tools;
  final String? nextCursor;

  ListToolsResult({required this.tools, this.nextCursor});

  factory ListToolsResult.fromJson(Map<String, dynamic> json) =>
      _$ListToolsResultFromJson(json);
  Map<String, dynamic> toJson() => _$ListToolsResultToJson(this);
}

/// Response result for 'tools/call' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class CallToolResult {
  final List<McpContent> content;
  final bool isError;

  CallToolResult({required this.content, this.isError = false});

  factory CallToolResult.fromJson(Map<String, dynamic> json) =>
      _$CallToolResultFromJson(json);
  Map<String, dynamic> toJson() => _$CallToolResultToJson(this);
}

/// Response result for 'resources/list' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ListResourcesResult {
  final List<McpResource> resources;
  final String? nextCursor;

  ListResourcesResult({required this.resources, this.nextCursor});

  factory ListResourcesResult.fromJson(Map<String, dynamic> json) =>
      _$ListResourcesResultFromJson(json);
  Map<String, dynamic> toJson() => _$ListResourcesResultToJson(this);
}

/// Response result for 'resources/read' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ReadResourceResult {
  final List<McpResourceContent> contents;

  ReadResourceResult({required this.contents});

  factory ReadResourceResult.fromJson(Map<String, dynamic> json) =>
      _$ReadResourceResultFromJson(json);
  Map<String, dynamic> toJson() => _$ReadResourceResultToJson(this);
}

/// Response result for 'prompts/list' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ListPromptsResult {
  final List<MCPPrompt> prompts;
  final String? nextCursor;

  ListPromptsResult({required this.prompts, this.nextCursor});

  factory ListPromptsResult.fromJson(Map<String, dynamic> json) =>
      _$ListPromptsResultFromJson(json);
  Map<String, dynamic> toJson() => _$ListPromptsResultToJson(this);
}

/// Response result for 'prompts/get' method
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GetPromptResult {
  final String? description;
  final List<McpPromptMessage> messages;

  GetPromptResult({this.description, required this.messages});

  factory GetPromptResult.fromJson(Map<String, dynamic> json) =>
      _$GetPromptResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetPromptResultToJson(this);
}
