// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitializeResult _$InitializeResultFromJson(Map<String, dynamic> json) =>
    InitializeResult(
      protocolVersion: json['protocol_version'] as String,
      capabilities: McpServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      serverInfo: McpImplementation.fromJson(
        json['server_info'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InitializeResultToJson(InitializeResult instance) =>
    <String, dynamic>{
      'protocol_version': instance.protocolVersion,
      'capabilities': instance.capabilities,
      'server_info': instance.serverInfo,
    };

ListToolsResult _$ListToolsResultFromJson(Map<String, dynamic> json) =>
    ListToolsResult(
      tools: (json['tools'] as List<dynamic>)
          .map((e) => McpTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$ListToolsResultToJson(ListToolsResult instance) =>
    <String, dynamic>{
      'tools': instance.tools,
      'next_cursor': instance.nextCursor,
    };

CallToolResult _$CallToolResultFromJson(Map<String, dynamic> json) =>
    CallToolResult(
      content: (json['content'] as List<dynamic>)
          .map((e) => McpContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      isError: json['is_error'] as bool? ?? false,
    );

Map<String, dynamic> _$CallToolResultToJson(CallToolResult instance) =>
    <String, dynamic>{
      'content': instance.content,
      'is_error': instance.isError,
    };

ListResourcesResult _$ListResourcesResultFromJson(Map<String, dynamic> json) =>
    ListResourcesResult(
      resources: (json['resources'] as List<dynamic>)
          .map((e) => McpResource.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$ListResourcesResultToJson(
  ListResourcesResult instance,
) => <String, dynamic>{
  'resources': instance.resources,
  'next_cursor': instance.nextCursor,
};

ReadResourceResult _$ReadResourceResultFromJson(Map<String, dynamic> json) =>
    ReadResourceResult(
      contents: (json['contents'] as List<dynamic>)
          .map((e) => McpResourceContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadResourceResultToJson(ReadResourceResult instance) =>
    <String, dynamic>{'contents': instance.contents};

ListPromptsResult _$ListPromptsResultFromJson(Map<String, dynamic> json) =>
    ListPromptsResult(
      prompts: (json['prompts'] as List<dynamic>)
          .map((e) => MCPPrompt.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$ListPromptsResultToJson(ListPromptsResult instance) =>
    <String, dynamic>{
      'prompts': instance.prompts,
      'next_cursor': instance.nextCursor,
    };

GetPromptResult _$GetPromptResultFromJson(Map<String, dynamic> json) =>
    GetPromptResult(
      description: json['description'] as String?,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => McpPromptMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetPromptResultToJson(GetPromptResult instance) =>
    <String, dynamic>{
      'description': instance.description,
      'messages': instance.messages,
    };
