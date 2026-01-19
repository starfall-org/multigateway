// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_tools.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpToolsList _$McpToolsListFromJson(Map<String, dynamic> json) => McpToolsList(
      json['id'] as String,
      json['name'] as String,
      (json['tools'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$McpToolsListToJson(McpToolsList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tools': instance.tools,
    };
