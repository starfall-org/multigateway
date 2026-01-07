// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_tools.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpServerTools _$McpServerToolsFromJson(Map<String, dynamic> json) =>
    McpServerTools(
      json['id'] as String,
      json['name'] as String,
      (json['tools'] as List<dynamic>)
          .map((e) => McpTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$McpServerToolsToJson(McpServerTools instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'tools': instance.tools.map((e) => e.toJson()).toList(),
    };

McpTool _$McpToolFromJson(Map<String, dynamic> json) => McpTool(
      json['name'] as String,
      json['description'] as String,
      (json['params'] as List<dynamic>)
          .map((e) => McpToolParam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$McpToolToJson(McpTool instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'params': instance.params.map((e) => e.toJson()).toList(),
    };

McpToolParam _$McpToolParamFromJson(Map<String, dynamic> json) => McpToolParam(
      json['name'] as String,
      json['value'] as String,
      json['description'] as String,
    );

Map<String, dynamic> _$McpToolParamToJson(McpToolParam instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'description': instance.description,
    };
