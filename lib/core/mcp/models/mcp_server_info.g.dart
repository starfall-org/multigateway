// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McpServerInfo _$McpServerInfoFromJson(Map<String, dynamic> json) =>
    McpServerInfo(
      json['id'] as String?,
      json['name'] as String,
      $enumDecode(_$McpProtocolEnumMap, json['protocol']),
      json['url'] as String?,
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      json['stdio_config'] == null
          ? null
          : StdioConfig.fromJson(json['stdio_config'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$McpServerInfoToJson(McpServerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'protocol': _$McpProtocolEnumMap[instance.protocol]!,
      'url': instance.url,
      'headers': instance.headers,
      'stdio_config': instance.stdioConfig?.toJson(),
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
