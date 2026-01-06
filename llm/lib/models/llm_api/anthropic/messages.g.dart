// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnthropicMessagesRequest _$AnthropicMessagesRequestFromJson(
  Map<String, dynamic> json,
) => AnthropicMessagesRequest(
  model: json['model'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => AnthropicMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  maxTokens: (json['max_tokens'] as num).toInt(),
  system: json['system'] as String?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => AnthropicTool.fromJson(e as Map<String, dynamic>))
      .toList(),
  toolChoice: json['tool_choice'],
  stream: json['stream'] as bool?,
);

Map<String, dynamic> _$AnthropicMessagesRequestToJson(
  AnthropicMessagesRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'max_tokens': instance.maxTokens,
  'system': instance.system,
  'temperature': instance.temperature,
  'tools': instance.tools?.map((e) => e.toJson()).toList(),
  'tool_choice': instance.toolChoice,
  'stream': instance.stream,
};

AnthropicMessage _$AnthropicMessageFromJson(Map<String, dynamic> json) =>
    AnthropicMessage(role: json['role'] as String, content: json['content']);

Map<String, dynamic> _$AnthropicMessageToJson(AnthropicMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

AnthropicContent _$AnthropicContentFromJson(Map<String, dynamic> json) =>
    AnthropicContent(
      type: json['type'] as String,
      text: json['text'] as String?,
      source: json['source'] as String?,
      mediaType: json['media_type'] as String?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$AnthropicContentToJson(AnthropicContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'source': instance.source,
      'media_type': instance.mediaType,
      'data': instance.data,
    };

AnthropicTool _$AnthropicToolFromJson(Map<String, dynamic> json) =>
    AnthropicTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['input_schema'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AnthropicToolToJson(AnthropicTool instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'input_schema': instance.inputSchema,
    };

AnthropicMessagesResponse _$AnthropicMessagesResponseFromJson(
  Map<String, dynamic> json,
) => AnthropicMessagesResponse(
  id: json['id'] as String,
  type: json['type'] as String,
  role: json['role'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => AnthropicContent.fromJson(e as Map<String, dynamic>))
      .toList(),
  model: json['model'] as String,
  stopReason: json['stop_reason'] as String?,
  stopSequence: json['stop_sequence'] as String?,
  usage: AnthropicUsage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnthropicMessagesResponseToJson(
  AnthropicMessagesResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'role': instance.role,
  'content': instance.content.map((e) => e.toJson()).toList(),
  'model': instance.model,
  'stop_reason': instance.stopReason,
  'stop_sequence': instance.stopSequence,
  'usage': instance.usage.toJson(),
};

AnthropicUsage _$AnthropicUsageFromJson(Map<String, dynamic> json) =>
    AnthropicUsage(
      inputTokens: (json['input_tokens'] as num).toInt(),
      outputTokens: (json['output_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$AnthropicUsageToJson(AnthropicUsage instance) =>
    <String, dynamic>{
      'input_tokens': instance.inputTokens,
      'output_tokens': instance.outputTokens,
    };
