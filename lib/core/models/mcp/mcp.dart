import 'mcp_core.dart';
import 'mcp_stdio.dart';
import 'mcp_http.dart';

export 'mcp_core.dart';
export 'mcp_stdio.dart';
export 'mcp_http.dart';

/// MCP Server Definition
/// Represents a complete MCP server configuration
/// Spec: https://spec.modelcontextprotocol.io/specification/
class MCPServer {
  /// Unique identifier/name for this server configuration
  final String name;

  /// Human-readable description
  final String? description;

  /// Transport protocol type
  final MCPTransportType transport;

  /// Configuration for stdio transport (required if transport is stdio)
  final MCPStdioConfig? stdioConfig;

  /// Configuration for HTTP transports (required if transport is sse or streamable)
  final MCPHttpConfig? httpConfig;

  /// Server capabilities (discovered after connection)
  final MCPServerCapabilities? capabilities;

  /// Available tools (discovered after connection)
  final List<MCPTool> tools;

  /// Available resources (discovered after connection)
  final List<MCPResource> resources;

  /// Available prompts (discovered after connection)
  final List<MCPPrompt> prompts;

  /// Whether this server is currently enabled
  final bool enabled;

  const MCPServer({
    required this.name,
    this.description,
    required this.transport,
    this.stdioConfig,
    this.httpConfig,
    this.capabilities,
    this.tools = const [],
    this.resources = const [],
    this.prompts = const [],
    this.enabled = true,
  });

  /// Create a stdio-based MCP server
  factory MCPServer.stdio({
    required String name,
    String? description,
    required String command,
    List<String> args = const [],
    Map<String, String>? env,
    String? cwd,
    bool enabled = true,
  }) {
    return MCPServer(
      name: name,
      description: description,
      transport: MCPTransportType.stdio,
      stdioConfig: MCPStdioConfig(
        command: command,
        args: args,
        env: env,
        cwd: cwd,
      ),
      enabled: enabled,
    );
  }

  /// Create an SSE-based MCP server
  factory MCPServer.sse({
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
    bool enabled = true,
  }) {
    return MCPServer(
      name: name,
      description: description,
      transport: MCPTransportType.sse,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
      enabled: enabled,
    );
  }

  /// Create a Streamable HTTP-based MCP server
  factory MCPServer.streamable({
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
    bool enabled = true,
  }) {
    return MCPServer(
      name: name,
      description: description,
      transport: MCPTransportType.streamable,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
      enabled: enabled,
    );
  }

  /// Create a copy with updated fields
  MCPServer copyWith({
    String? name,
    String? description,
    MCPTransportType? transport,
    MCPStdioConfig? stdioConfig,
    MCPHttpConfig? httpConfig,
    MCPServerCapabilities? capabilities,
    List<MCPTool>? tools,
    List<MCPResource>? resources,
    List<MCPPrompt>? prompts,
    bool? enabled,
  }) {
    return MCPServer(
      name: name ?? this.name,
      description: description ?? this.description,
      transport: transport ?? this.transport,
      stdioConfig: stdioConfig ?? this.stdioConfig,
      httpConfig: httpConfig ?? this.httpConfig,
      capabilities: capabilities ?? this.capabilities,
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      prompts: prompts ?? this.prompts,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'transport': transport.name,
      if (stdioConfig != null) 'stdioConfig': stdioConfig!.toJson(),
      if (httpConfig != null) 'httpConfig': httpConfig!.toJson(),
      if (capabilities != null) 'capabilities': capabilities!.toJson(),
      'tools': tools.map((t) => t.toJson()).toList(),
      'resources': resources.map((r) => r.toJson()).toList(),
      'prompts': prompts.map((p) => p.toJson()).toList(),
      'enabled': enabled,
    };
  }

  factory MCPServer.fromJson(Map<String, dynamic> json) {
    return MCPServer(
      name: json['name'] as String,
      description: json['description'] as String?,
      transport: MCPTransportType.values.firstWhere(
        (e) => e.name == json['transport'],
        orElse: () => MCPTransportType.sse,
      ),
      stdioConfig: json['stdioConfig'] != null
          ? MCPStdioConfig.fromJson(json['stdioConfig'] as Map<String, dynamic>)
          : null,
      httpConfig: json['httpConfig'] != null
          ? MCPHttpConfig.fromJson(json['httpConfig'] as Map<String, dynamic>)
          : null,
      capabilities: json['capabilities'] != null
          ? MCPServerCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            )
          : null,
      tools:
          (json['tools'] as List?)
              ?.map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      resources:
          (json['resources'] as List?)
              ?.map((r) => MCPResource.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      prompts:
          (json['prompts'] as List?)
              ?.map((p) => MCPPrompt.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
