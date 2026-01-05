import 'package:json_annotation/json_annotation.dart';

part 'mcp_core.g.dart';

/// MCP Transport Protocol Types
/// - streamable: Streamable HTTP (recommended for new implementations)
/// - sse: Server-Sent Events over HTTP
/// - stdio: Standard input/output (for local processes)
enum MCPTransportType { streamable, sse, stdio }

/// JSON Schema representation for MCP Tool input validation
/// Follows JSON Schema specification (https://json-schema.org/)
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class JsonSchema {
  final String type;
  @JsonKey(fromJson: _propertiesFromJson, toJson: _propertiesToJson)
  final Map<String, JsonSchemaProperty>? properties;
  final List<String>? required;
  final String? description;
  final dynamic additionalProperties;

  const JsonSchema({
    this.type = 'object',
    this.properties,
    this.required,
    this.description,
    this.additionalProperties,
  });

  factory JsonSchema.fromJson(Map<String, dynamic> json) => _$JsonSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$JsonSchemaToJson(this);

  static Map<String, JsonSchemaProperty>? _propertiesFromJson(dynamic json) {
    if (json == null) return null;
    if (json is! Map) return null;
    return (json as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, JsonSchemaProperty.fromJson(v as Map<String, dynamic>)),
    );
  }

  static Map<String, dynamic>? _propertiesToJson(Map<String, JsonSchemaProperty>? properties) {
    return properties?.map((k, v) => MapEntry(k, v.toJson()));
  }
}

/// Property definition within a JSON Schema
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class JsonSchemaProperty {
  final String type;
  final String? description;
  @JsonKey(name: 'enum')
  final List<String>? enumValues;
  @JsonKey(name: 'default')
  final dynamic defaultValue;
  final JsonSchema? items; // For array types

  const JsonSchemaProperty({
    required this.type,
    this.description,
    this.enumValues,
    this.defaultValue,
    this.items,
  });

  factory JsonSchemaProperty.fromJson(Map<String, dynamic> json) => _$JsonSchemaPropertyFromJson(json);
  Map<String, dynamic> toJson() => _$JsonSchemaPropertyToJson(this);
}

/// MCP Tool Definition
/// Tools enable LLMs to perform actions through the MCP server
/// Spec: https://spec.modelcontextprotocol.io/specification/server/tools/
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPTool {
  /// Unique identifier for the tool
  final String name;

  /// Human-readable description of what the tool does
  final String? description;

  /// JSON Schema defining the expected parameters for the tool
  final JsonSchema inputSchema;

  /// Whether this tool is enabled
  @JsonKey(defaultValue: true)
  final bool enabled;

  const MCPTool({
    required this.name,
    this.description,
    required this.inputSchema,
    this.enabled = true,
  });

  factory MCPTool.fromJson(Map<String, dynamic> json) => _$MCPToolFromJson(json);
  Map<String, dynamic> toJson() => _$MCPToolToJson(this);
}

/// MCP Resource Definition
/// Resources represent data that an MCP server makes available to clients
/// Spec: https://spec.modelcontextprotocol.io/specification/server/resources/
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
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

  factory MCPResource.fromJson(Map<String, dynamic> json) => _$MCPResourceFromJson(json);
  Map<String, dynamic> toJson() => _$MCPResourceToJson(this);
}

/// MCP Prompt Argument Definition
/// Arguments that can be passed to a prompt template
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPPromptArgument {
  /// Argument name
  final String name;

  /// Human-readable description
  final String? description;

  /// Whether this argument is required
  @JsonKey(defaultValue: false)
  final bool required;

  const MCPPromptArgument({
    required this.name,
    this.description,
    this.required = false,
  });

  factory MCPPromptArgument.fromJson(Map<String, dynamic> json) => _$MCPPromptArgumentFromJson(json);
  Map<String, dynamic> toJson() => _$MCPPromptArgumentToJson(this);
}

/// MCP Prompt Definition
/// Prompts are reusable templates that can be invoked by clients
/// Spec: https://spec.modelcontextprotocol.io/specification/server/prompts/
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPPrompt {
  /// Unique identifier for the prompt
  final String name;

  /// Human-readable description
  final String? description;

  /// Arguments that can be passed to the prompt
  final List<MCPPromptArgument>? arguments;

  const MCPPrompt({required this.name, this.description, this.arguments});

  factory MCPPrompt.fromJson(Map<String, dynamic> json) => _$MCPPromptFromJson(json);
  Map<String, dynamic> toJson() => _$MCPPromptToJson(this);
}

/// MCP Server Capabilities
/// Describes what features the server supports
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPServerCapabilities {
  /// Server supports tools
  @JsonKey(defaultValue: false)
  final bool tools;

  /// Server supports resources
  @JsonKey(defaultValue: false)
  final bool resources;

  /// Server supports prompts
  @JsonKey(defaultValue: false)
  final bool prompts;

  /// Server supports logging
  @JsonKey(defaultValue: false)
  final bool logging;

  const MCPServerCapabilities({
    this.tools = false,
    this.resources = false,
    this.prompts = false,
    this.logging = false,
  });

  factory MCPServerCapabilities.fromJson(Map<String, dynamic> json) {
    // Special handling: if key exists, it's true
    return MCPServerCapabilities(
      tools: json.containsKey('tools'),
      resources: json.containsKey('resources'),
      prompts: json.containsKey('prompts'),
      logging: json.containsKey('logging'),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (tools) json['tools'] = {};
    if (resources) json['resources'] = {};
    if (prompts) json['prompts'] = {};
    if (logging) json['logging'] = {};
    return json;
  }
}

/// Information about an MCP implementation (client or server)
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPImplementation {
  final String name;
  final String version;

  const MCPImplementation({required this.name, required this.version});

  factory MCPImplementation.fromJson(Map<String, dynamic> json) => _$MCPImplementationFromJson(json);
  Map<String, dynamic> toJson() => _$MCPImplementationToJson(this);
}

/// Base class for content shared in MCP messages
abstract class MCPContent {
  final String type;
  const MCPContent(this.type);
  Map<String, dynamic> toJson();

  factory MCPContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'text':
        return MCPTextContent.fromJson(json);
      case 'image':
        return MCPImageContent.fromJson(json);
      case 'resource':
        return MCPResourceContent.fromJson(json);
      default:
        throw Exception('Unknown content type: $type');
    }
  }
}

/// Textual content
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPTextContent extends MCPContent {
  final String text;
  const MCPTextContent(this.text) : super('text');

  @override
  Map<String, dynamic> toJson() => _$MCPTextContentToJson(this);

  factory MCPTextContent.fromJson(Map<String, dynamic> json) => _$MCPTextContentFromJson(json);
}

/// Image content
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPImageContent extends MCPContent {
  final String data;
  final String mimeType;
  const MCPImageContent({required this.data, required this.mimeType})
    : super('image');

  @override
  Map<String, dynamic> toJson() => _$MCPImageContentToJson(this);

  factory MCPImageContent.fromJson(Map<String, dynamic> json) => _$MCPImageContentFromJson(json);
}

/// Content representing a resource
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPResourceContent extends MCPContent {
  final String uri;
  final String? mimeType;
  final String? text;
  final String? blob;

  const MCPResourceContent({
    required this.uri,
    this.mimeType,
    this.text,
    this.blob,
  }) : super('resource');

  @override
  Map<String, dynamic> toJson() => _$MCPResourceContentToJson(this);

  factory MCPResourceContent.fromJson(Map<String, dynamic> json) => _$MCPResourceContentFromJson(json);
}

/// A message in a prompt or sampling context
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class MCPPromptMessage {
  final String role; // 'user' or 'assistant'
  @JsonKey(fromJson: _contentFromJson, toJson: _contentToJson)
  final MCPContent content;

  const MCPPromptMessage({required this.role, required this.content});

  factory MCPPromptMessage.fromJson(Map<String, dynamic> json) => _$MCPPromptMessageFromJson(json);
  Map<String, dynamic> toJson() => _$MCPPromptMessageToJson(this);

  static MCPContent _contentFromJson(Map<String, dynamic> json) => MCPContent.fromJson(json);
  static Map<String, dynamic> _contentToJson(MCPContent content) => content.toJson();
}
