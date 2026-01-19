import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'mcp_info.g.dart';

enum McpProtocol { streamableHttp, sse, stdio }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpInfo {
  final String id;
  final String name;
  final McpProtocol protocol;
  final String? url;
  final Map<String, String>? headers;

  McpInfo(String? id, this.name, this.protocol, this.url, this.headers)
    : id = id ?? Uuid().v4();

  factory McpInfo.fromJson(Map<String, dynamic> json) =>
      _$McpInfoFromJson(json);

  Map<String, dynamic> toJson() => _$McpInfoToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class StdioConfig {
  final String execBinaryPath;
  final String execArgs;
  final String execFilePath;

  StdioConfig(this.execBinaryPath, this.execArgs, this.execFilePath);

  factory StdioConfig.fromJson(Map<String, dynamic> json) =>
      _$StdioConfigFromJson(json);

  Map<String, dynamic> toJson() => _$StdioConfigToJson(this);
}
