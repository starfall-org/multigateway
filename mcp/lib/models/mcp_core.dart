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

  factory JsonSchema.fromJson(Map<String, dynamic> json) =>
      _$JsonSchemaFromJson(json);
  Map<String, dynamic> toJson() => _$JsonSchemaToJson(this);

  static Map<String, JsonSchemaProperty>? _propertiesFromJson(dynamic json) {
    if (json == null) return null;
    if (json is! Map) return null;
    return (json as Map<String, dynamic>).map(
      (k, v) =>
          MapEntry(k, JsonSchemaProperty.fromJson(v as Map<String, dynamic>)),
    );
  }

  static Map<String, dynamic>? _propertiesToJson(
    Map<String, JsonSchemaProperty>? properties,
  ) {
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

  factory JsonSchemaProperty.fromJson(Map<String, dynamic> json) =>
      _$JsonSchemaPropertyFromJson(json);
  Map<String, dynamic> toJson() => _$JsonSchemaPropertyToJson(this);
}

/// MCP Tool Definition
/// Tools enable LLMs to perform actions through the MCP server
/// Spec: https://spec.modelcontextprotocol.io/specification/server/tools/
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpTool {
  /// Unique identifier for the tool
  final String name;

  /// Human-readable description of what the tool does
  final String? description;

  /// JSON Schema defining the expected parameters for the tool
  final JsonSchema inputSchema;

  /// Whether this tool is enabled
  @JsonKey(defaultValue: true)
  final bool enabled;

  const McpTool({
    required this.name,
    this.description,
    required this.inputSchema,
    this.enabled = true,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) =>
      _$McpToolFromJson(json);
  Map<String, dynamic> toJson() => _$McpToolToJson(this);
}

/// MCP Resource Definition
/// Resources represent data that an MCP server makes available to clients
/// Spec: https://spec.modelcontextprotocol.io/specification/server/resources/
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpResource {
  /// Unique identifier for the resource (URI format)
  final String uri;

  /// Human-readable name for the resource
  final String name;

  /// Description of what the resource represents
  final String? description;

  /// MIME type of the resource content
  final String? mimeType;

  const McpResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  factory McpResource.fromJson(Map<String, dynamic> json) =>
      _$McpResourceFromJson(json);
  Map<String, dynamic> toJson() => _$McpResourceToJson(this);
}

/// MCP Prompt Argument Definition
/// Arguments that can be passed to a prompt template
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpPromptArgument {
  /// Argument name
  final String name;

  /// Human-readable description
  final String? description;

  /// Whether this argument is required
  @JsonKey(defaultValue: false)
  final bool required;

  const McpPromptArgument({
    required this.name,
    this.description,
    this.required = false,
  });

  factory McpPromptArgument.fromJson(Map<String, dynamic> json) =>
      _$McpPromptArgumentFromJson(json);
  Map<String, dynamic> toJson() => _$McpPromptArgumentToJson(this);
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
  final List<McpPromptArgument>? arguments;

  const MCPPrompt({required this.name, this.description, this.arguments});

  factory MCPPrompt.fromJson(Map<String, dynamic> json) =>
      _$MCPPromptFromJson(json);
  Map<String, dynamic> toJson() => _$MCPPromptToJson(this);
}

/// MCP Server Capabilities
/// Describes what features the server supports
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpServerCapabilities {
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

  const McpServerCapabilities({
    this.tools = false,
    this.resources = false,
    this.prompts = false,
    this.logging = false,
  });

  factory McpServerCapabilities.fromJson(Map<String, dynamic> json) =>
      _$McpServerCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerCapabilitiesToJson(this);
}

/// Information about an MCP implementation (client or server)
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpImplementation {
  final String name;
  final String version;

  const McpImplementation({required this.name, required this.version});

  factory McpImplementation.fromJson(Map<String, dynamic> json) =>
      _$McpImplementationFromJson(json);
  Map<String, dynamic> toJson() => _$McpImplementationToJson(this);
}

/// Base class for content shared in MCP messages
abstract class McpContent {
  final String type;
  const McpContent(this.type);
  Map<String, dynamic> toJson();

  factory McpContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'text':
        return McpTextContent.fromJson(json);
      case 'image':
        return McpImageContent.fromJson(json);
      case 'resource':
        return McpResourceContent.fromJson(json);
      default:
        throw Exception('Unknown content type: $type');
    }
  }
}

/// Textual content
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpTextContent extends McpContent {
  final String text;
  const McpTextContent(this.text) : super('text');

  @override
  Map<String, dynamic> toJson() => _$McpTextContentToJson(this);

  factory McpTextContent.fromJson(Map<String, dynamic> json) =>
      _$McpTextContentFromJson(json);
}

/// Image content
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpImageContent extends McpContent {
  final String data;
  final String mimeType;
  const McpImageContent({required this.data, required this.mimeType})
    : super('image');

  @override
  Map<String, dynamic> toJson() => _$McpImageContentToJson(this);

  factory McpImageContent.fromJson(Map<String, dynamic> json) =>
      _$McpImageContentFromJson(json);
}

/// Content representing a resource
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpResourceContent extends McpContent {
  final String uri;
  final String? mimeType;
  final String? text;
  final String? blob;

  const McpResourceContent({
    required this.uri,
    this.mimeType,
    this.text,
    this.blob,
  }) : super('resource');

  @override
  Map<String, dynamic> toJson() => _$McpResourceContentToJson(this);

  factory McpResourceContent.fromJson(Map<String, dynamic> json) =>
      _$McpResourceContentFromJson(json);
}

/// A message in a prompt or sampling context
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpPromptMessage {
  final String role; // 'user' or 'assistant'
  @JsonKey(fromJson: _contentFromJson, toJson: _contentToJson)
  final McpContent content;

  const McpPromptMessage({required this.role, required this.content});

  factory McpPromptMessage.fromJson(Map<String, dynamic> json) =>
      _$McpPromptMessageFromJson(json);
  Map<String, dynamic> toJson() => _$McpPromptMessageToJson(this);

  static McpContent _contentFromJson(Map<String, dynamic> json) =>
      McpContent.fromJson(json);
  static Map<String, dynamic> _contentToJson(McpContent content) =>
      content.toJson();
}
