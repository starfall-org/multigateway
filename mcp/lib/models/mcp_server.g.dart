// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpServer _$McpServerFromJson(Map<String, dynamic> json) => McpServer(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  transport: $enumDecode(_$MCPTransportTypeEnumMap, json['transport']),
  httpConfig: json['http_config'] == null
      ? null
      : MCPHttpConfig.fromJson(json['http_config'] as Map<String, dynamic>),
  capabilities: json['capabilities'] == null
      ? null
      : McpServerCapabilities.fromJson(
          json['capabilities'] as Map<String, dynamic>,
        ),
  tools:
      (json['tools'] as List<dynamic>?)
          ?.map((e) => McpTool.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  resources:
      (json['resources'] as List<dynamic>?)
          ?.map((e) => McpResource.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  prompts:
      (json['prompts'] as List<dynamic>?)
          ?.map((e) => MCPPrompt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$McpServerToJson(McpServer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'transport': _$MCPTransportTypeEnumMap[instance.transport]!,
  'http_config': instance.httpConfig?.toJson(),
  'capabilities': instance.capabilities?.toJson(),
  'tools': instance.tools.map((e) => e.toJson()).toList(),
  'resources': instance.resources.map((e) => e.toJson()).toList(),
  'prompts': instance.prompts.map((e) => e.toJson()).toList(),
};

const _$MCPTransportTypeEnumMap = {
  MCPTransportType.streamable: 'streamable',
  MCPTransportType.sse: 'sse',
  MCPTransportType.stdio: 'stdio',
};
