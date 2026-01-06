import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'mcp_server_info.g.dart';

enum McpProtocol { streamableHttp, sse, stdio }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpServerInfo {
  final String id;
  final String name;
  final McpProtocol protocol;
  final String? url;
  final StdioConfig? stdioConfig;

  McpServerInfo(
    String? id,
    this.name,
    this.protocol,
    this.url,
    this.stdioConfig,
  ) : id = id ?? Uuid().v4();

  factory McpServerInfo.fromJson(Map<String, dynamic> json) =>
      _$McpServerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerInfoToJson(this);
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
