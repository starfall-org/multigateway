import 'package:json_annotation/json_annotation.dart';
import 'package:mcp/models/mcp_core.dart';
import 'package:mcp/models/mcp_http.dart';
import 'package:uuid/uuid.dart';

export 'mcp_core.dart';
export 'mcp_http.dart';

part 'mcp_server.g.dart';

enum MCPTransportType { streamable, sse, stdio }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpServer {
  final String id;
  final String name;
  final String? description;
  final MCPTransportType transport;
  final MCPHttpConfig? httpConfig;
  final McpServerCapabilities? capabilities;
  final List<McpTool> tools;
  final List<McpResource> resources;
  final List<MCPPrompt> prompts;

  const McpServer({
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

  factory McpServer.stdio({
    String? id,
    required String name,
    String? description,
    required String command,
    List<String> args = const [],
    Map<String, String>? env,
    String? cwd,
  }) {
    return McpServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.stdio,
      httpConfig: null,
    );
  }

  factory McpServer.sse({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return McpServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.sse,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  factory McpServer.streamable({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return McpServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.streamable,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  McpServer copyWith({
    String? id,
    String? name,
    String? description,
    MCPTransportType? transport,
    MCPHttpConfig? httpConfig,
    McpServerCapabilities? capabilities,
    List<McpTool>? tools,
    List<McpResource>? resources,
    List<MCPPrompt>? prompts,
  }) {
    return McpServer(
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

  factory McpServer.fromJson(Map<String, dynamic> json) =>
      _$McpServerFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerToJson(this);
}
