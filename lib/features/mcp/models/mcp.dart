/// MCP Transport Protocol Types
/// - streamable: Streamable HTTP (recommended for new implementations)
/// - sse: Server-Sent Events over HTTP
/// - stdio: Standard input/output (for local processes)
enum MCPTransportType { streamable, sse, stdio }

/// JSON Schema representation for MCP Tool input validation
/// Follows JSON Schema specification (https://json-schema.org/)
class JsonSchema {
  final String type;
  final Map<String, JsonSchemaProperty>? properties;
  final List<String>? required;
  final String? description;
  final Map<String, dynamic>? additionalProperties;

  const JsonSchema({
    this.type = 'object',
    this.properties,
    this.required,
    this.description,
    this.additionalProperties,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (properties != null) {
      json['properties'] = properties!.map((k, v) => MapEntry(k, v.toJson()));
    }
    if (required != null) json['required'] = required;
    if (description != null) json['description'] = description;
    if (additionalProperties != null) {
      json['additionalProperties'] = additionalProperties;
    }
    return json;
  }

  factory JsonSchema.fromJson(Map<String, dynamic> json) {
    return JsonSchema(
      type: json['type'] as String? ?? 'object',
      properties: json['properties'] != null
          ? (json['properties'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, JsonSchemaProperty.fromJson(v)),
            )
          : null,
      required: (json['required'] as List?)?.cast<String>(),
      description: json['description'] as String?,
      additionalProperties: json['additionalProperties'] as Map<String, dynamic>?,
    );
  }
}

/// Property definition within a JSON Schema
class JsonSchemaProperty {
  final String type;
  final String? description;
  final List<String>? enumValues;
  final dynamic defaultValue;
  final JsonSchema? items; // For array types

  const JsonSchemaProperty({
    required this.type,
    this.description,
    this.enumValues,
    this.defaultValue,
    this.items,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};
    if (description != null) json['description'] = description;
    if (enumValues != null) json['enum'] = enumValues;
    if (defaultValue != null) json['default'] = defaultValue;
    if (items != null) json['items'] = items!.toJson();
    return json;
  }

  factory JsonSchemaProperty.fromJson(Map<String, dynamic> json) {
    return JsonSchemaProperty(
      type: json['type'] as String? ?? 'string',
      description: json['description'] as String?,
      enumValues: (json['enum'] as List?)?.cast<String>(),
      defaultValue: json['default'],
      items: json['items'] != null
          ? JsonSchema.fromJson(json['items'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// MCP Tool Definition
/// Tools enable LLMs to perform actions through the MCP server
/// Spec: https://spec.modelcontextprotocol.io/specification/server/tools/
class MCPTool {
  /// Unique identifier for the tool
  final String name;

  /// Human-readable description of what the tool does
  final String? description;

  /// JSON Schema defining the expected parameters for the tool
  final JsonSchema inputSchema;

  const MCPTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'inputSchema': inputSchema.toJson(),
    };
  }

  factory MCPTool.fromJson(Map<String, dynamic> json) {
    return MCPTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: JsonSchema.fromJson(
        json['inputSchema'] as Map<String, dynamic>? ?? {'type': 'object'},
      ),
    );
  }
}

/// MCP Resource Definition
/// Resources represent data that an MCP server makes available to clients
/// Spec: https://spec.modelcontextprotocol.io/specification/server/resources/
class MCPResource {
  /// Unique identifier for the resource (URI format)
  final String uri;

  /// Human-readable name for the resource
  final String name;

  /// Description of what the resource represents
  final String? description;

  /// MIME type of the resource content
  final String? mimeType;

  const MCPResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
      if (description != null) 'description': description,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }

  factory MCPResource.fromJson(Map<String, dynamic> json) {
    return MCPResource(
      uri: json['uri'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }
}

/// MCP Prompt Argument Definition
/// Arguments that can be passed to a prompt template
class MCPPromptArgument {
  /// Argument name
  final String name;

  /// Human-readable description
  final String? description;

  /// Whether this argument is required
  final bool required;

  const MCPPromptArgument({
    required this.name,
    this.description,
    this.required = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (required) 'required': required,
    };
  }

  factory MCPPromptArgument.fromJson(Map<String, dynamic> json) {
    return MCPPromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
    );
  }
}

/// MCP Prompt Definition
/// Prompts are reusable templates that can be invoked by clients
/// Spec: https://spec.modelcontextprotocol.io/specification/server/prompts/
class MCPPrompt {
  /// Unique identifier for the prompt
  final String name;

  /// Human-readable description
  final String? description;

  /// Arguments that can be passed to the prompt
  final List<MCPPromptArgument>? arguments;

  const MCPPrompt({
    required this.name,
    this.description,
    this.arguments,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (arguments != null)
        'arguments': arguments!.map((a) => a.toJson()).toList(),
    };
  }

  factory MCPPrompt.fromJson(Map<String, dynamic> json) {
    return MCPPrompt(
      name: json['name'] as String,
      description: json['description'] as String?,
      arguments: (json['arguments'] as List?)
          ?.map((a) => MCPPromptArgument.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Configuration for stdio transport
/// Used when MCP server runs as a local subprocess
class MCPStdioConfig {
  /// Command to execute (e.g., 'npx', 'python', 'node')
  final String command;

  /// Arguments to pass to the command
  final List<String> args;

  /// Environment variables for the subprocess
  final Map<String, String>? env;

  /// Working directory for the subprocess
  final String? cwd;

  const MCPStdioConfig({
    required this.command,
    this.args = const [],
    this.env,
    this.cwd,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'args': args,
      if (env != null) 'env': env,
      if (cwd != null) 'cwd': cwd,
    };
  }

  factory MCPStdioConfig.fromJson(Map<String, dynamic> json) {
    return MCPStdioConfig(
      command: json['command'] as String,
      args: (json['args'] as List?)?.cast<String>() ?? [],
      env: (json['env'] as Map<String, dynamic>?)?.cast<String, String>(),
      cwd: json['cwd'] as String?,
    );
  }
}

/// Configuration for HTTP-based transports (SSE, Streamable HTTP)
class MCPHttpConfig {
  /// Server URL endpoint
  final String url;

  /// Optional headers for authentication or other purposes
  final Map<String, String>? headers;

  const MCPHttpConfig({
    required this.url,
    this.headers,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (headers != null) 'headers': headers,
    };
  }

  factory MCPHttpConfig.fromJson(Map<String, dynamic> json) {
    return MCPHttpConfig(
      url: json['url'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
}

/// MCP Server Capabilities
/// Describes what features the server supports
class MCPServerCapabilities {
  /// Server supports tools
  final bool tools;

  /// Server supports resources
  final bool resources;

  /// Server supports prompts
  final bool prompts;

  /// Server supports logging
  final bool logging;

  const MCPServerCapabilities({
    this.tools = false,
    this.resources = false,
    this.prompts = false,
    this.logging = false,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (tools) json['tools'] = {};
    if (resources) json['resources'] = {};
    if (prompts) json['prompts'] = {};
    if (logging) json['logging'] = {};
    return json;
  }

  factory MCPServerCapabilities.fromJson(Map<String, dynamic> json) {
    return MCPServerCapabilities(
      tools: json.containsKey('tools'),
      resources: json.containsKey('resources'),
      prompts: json.containsKey('prompts'),
      logging: json.containsKey('logging'),
    );
  }
}

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
              json['capabilities'] as Map<String, dynamic>)
          : null,
      tools: (json['tools'] as List?)
              ?.map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      resources: (json['resources'] as List?)
              ?.map((r) => MCPResource.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      prompts: (json['prompts'] as List?)
              ?.map((p) => MCPPrompt.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
