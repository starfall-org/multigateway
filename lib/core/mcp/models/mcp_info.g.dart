// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpInfo _$McpInfoFromJson(Map<String, dynamic> json) => McpInfo(
      json['id'] as String?,
      json['name'] as String,
      $enumDecode(_$McpProtocolEnumMap, json['protocol']),
      json['url'] as String?,
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$McpInfoToJson(McpInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'protocol': _$McpProtocolEnumMap[instance.protocol]!,
      'url': instance.url,
      'headers': instance.headers,
    };

const _$McpProtocolEnumMap = {
  McpProtocol.streamableHttp: 'streamableHttp',
  McpProtocol.sse: 'sse',
  McpProtocol.stdio: 'stdio',
};

StdioConfig _$StdioConfigFromJson(Map<String, dynamic> json) => StdioConfig(
      json['exec_binary_path'] as String,
      json['exec_args'] as String,
      json['exec_file_path'] as String,
    );

Map<String, dynamic> _$StdioConfigToJson(StdioConfig instance) =>
    <String, dynamic>{
      'exec_binary_path': instance.execBinaryPath,
      'exec_args': instance.execArgs,
      'exec_file_path': instance.execFilePath,
    };
