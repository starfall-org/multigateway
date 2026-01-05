import 'package:uuid/uuid.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mcp_core.dart';
import 'mcp_http.dart';

export 'mcp_core.dart';
export 'mcp_http.dart';

part 'mcp_server.g.dart';

enum MCPTransportType { streamable, sse, stdio }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPServer {
  final String id;
  final String name;
  final String? description;
  final MCPTransportType transport;
  final MCPHttpConfig? httpConfig;
  final MCPServerCapabilities? capabilities;
  final List<MCPTool> tools;
  final List<MCPResource> resources;
  final List<MCPPrompt> prompts;

  const MCPServer({
    required this.id,
    required this.name,
    this.description,
    required this.transport,
    this.httpConfig,
    this.capabilities,
    this.tools = const [],
    this.resources = const [],
    this.prompts = const [],
  });

  factory MCPServer.stdio({
    String? id,
    required String name,
    String? description,
    required String command,
    List<String> args = const [],
    Map<String, String>? env,
    String? cwd,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.stdio,
      httpConfig: null,
    );
  }

  factory MCPServer.sse({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.sse,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  factory MCPServer.streamable({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.streamable,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  MCPServer copyWith({
    String? id,
    String? name,
    String? description,
    MCPTransportType? transport,
    MCPHttpConfig? httpConfig,
    MCPServerCapabilities? capabilities,
    List<MCPTool>? tools,
    List<MCPResource>? resources,
    List<MCPPrompt>? prompts,
  }) {
    return MCPServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      transport: transport ?? this.transport,
      httpConfig: httpConfig ?? this.httpConfig,
      capabilities: capabilities ?? this.capabilities,
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      prompts: prompts ?? this.prompts,
    );
  }

  factory MCPServer.fromJson(Map<String, dynamic> json) =>
      _$MCPServerFromJson(json);

  Map<String, dynamic> toJson() => _$MCPServerToJson(this);
}
