// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_core.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonSchema _$JsonSchemaFromJson(Map<String, dynamic> json) => JsonSchema(
  type: json['type'] as String? ?? 'object',
  properties: JsonSchema._propertiesFromJson(json['properties']),
  required: (json['required'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  description: json['description'] as String?,
  additionalProperties: json['additional_properties'],
);

Map<String, dynamic> _$JsonSchemaToJson(JsonSchema instance) =>
    <String, dynamic>{
      'type': instance.type,
      'properties': JsonSchema._propertiesToJson(instance.properties),
      'required': instance.required,
      'description': instance.description,
      'additional_properties': instance.additionalProperties,
    };

JsonSchemaProperty _$JsonSchemaPropertyFromJson(Map<String, dynamic> json) =>
    JsonSchemaProperty(
      type: json['type'] as String,
      description: json['description'] as String?,
      enumValues: (json['enum'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defaultValue: json['default'],
      items: json['items'] == null
          ? null
          : JsonSchema.fromJson(json['items'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JsonSchemaPropertyToJson(JsonSchemaProperty instance) =>
    <String, dynamic>{
      'type': instance.type,
      'description': instance.description,
      'enum': instance.enumValues,
      'default': instance.defaultValue,
      'items': instance.items?.toJson(),
    };

McpTool _$McpToolFromJson(Map<String, dynamic> json) => McpTool(
  name: json['name'] as String,
  description: json['description'] as String?,
  inputSchema: JsonSchema.fromJson(
    json['input_schema'] as Map<String, dynamic>,
  ),
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$McpToolToJson(McpTool instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'input_schema': instance.inputSchema.toJson(),
  'enabled': instance.enabled,
};

McpResource _$McpResourceFromJson(Map<String, dynamic> json) => McpResource(
  uri: json['uri'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  mimeType: json['mime_type'] as String?,
);

Map<String, dynamic> _$McpResourceToJson(McpResource instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'name': instance.name,
      'description': instance.description,
      'mime_type': instance.mimeType,
    };

McpPromptArgument _$McpPromptArgumentFromJson(Map<String, dynamic> json) =>
    McpPromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
    );

Map<String, dynamic> _$McpPromptArgumentToJson(McpPromptArgument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
    };

MCPPrompt _$MCPPromptFromJson(Map<String, dynamic> json) => MCPPrompt(
  name: json['name'] as String,
  description: json['description'] as String?,
  arguments: (json['arguments'] as List<dynamic>?)
      ?.map((e) => McpPromptArgument.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MCPPromptToJson(MCPPrompt instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'arguments': instance.arguments?.map((e) => e.toJson()).toList(),
};

McpServerCapabilities _$McpServerCapabilitiesFromJson(
  Map<String, dynamic> json,
) => McpServerCapabilities(
  tools: json['tools'] as bool? ?? false,
  resources: json['resources'] as bool? ?? false,
  prompts: json['prompts'] as bool? ?? false,
  logging: json['logging'] as bool? ?? false,
);

Map<String, dynamic> _$McpServerCapabilitiesToJson(
  McpServerCapabilities instance,
) => <String, dynamic>{
  'tools': instance.tools,
  'resources': instance.resources,
  'prompts': instance.prompts,
  'logging': instance.logging,
};

McpImplementation _$McpImplementationFromJson(Map<String, dynamic> json) =>
    McpImplementation(
      name: json['name'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$McpImplementationToJson(McpImplementation instance) =>
    <String, dynamic>{'name': instance.name, 'version': instance.version};

McpTextContent _$McpTextContentFromJson(Map<String, dynamic> json) =>
    McpTextContent(json['text'] as String);

Map<String, dynamic> _$McpTextContentToJson(McpTextContent instance) =>
    <String, dynamic>{'text': instance.text};

McpImageContent _$McpImageContentFromJson(Map<String, dynamic> json) =>
    McpImageContent(
      data: json['data'] as String,
      mimeType: json['mime_type'] as String,
    );

Map<String, dynamic> _$McpImageContentToJson(McpImageContent instance) =>
    <String, dynamic>{'data': instance.data, 'mime_type': instance.mimeType};

McpResourceContent _$McpResourceContentFromJson(Map<String, dynamic> json) =>
    McpResourceContent(
      uri: json['uri'] as String,
      mimeType: json['mime_type'] as String?,
      text: json['text'] as String?,
      blob: json['blob'] as String?,
    );

Map<String, dynamic> _$McpResourceContentToJson(McpResourceContent instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'mime_type': instance.mimeType,
      'text': instance.text,
      'blob': instance.blob,
    };

McpPromptMessage _$McpPromptMessageFromJson(Map<String, dynamic> json) =>
    McpPromptMessage(
      role: json['role'] as String,
      content: McpPromptMessage._contentFromJson(
        json['content'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$McpPromptMessageToJson(McpPromptMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': McpPromptMessage._contentToJson(instance.content),
    };
