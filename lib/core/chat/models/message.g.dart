// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageContents _$MessageContentsFromJson(Map<String, dynamic> json) =>
    MessageContents(
      content: json['content'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reasoningContent: json['reasoning_content'] as String?,
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      toolCall: json['tool_call'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MessageContentsToJson(MessageContents instance) =>
    <String, dynamic>{
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'reasoning_content': instance.reasoningContent,
      'files': instance.files,
      'tool_call': instance.toolCall,
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      role: $enumDecode(_$ChatRoleEnumMap, json['role']),
      versions: (json['versions'] as List<dynamic>?)
          ?.map((e) => MessageContents.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentVersionIndex:
          (json['current_version_index'] as num?)?.toInt() ?? 0,
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      reasoningContent: json['reasoning_content'] as String?,
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      toolCall: json['tool_call'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$ChatRoleEnumMap[instance.role]!,
      'versions': instance.versions.map((e) => e.toJson()).toList(),
      'current_version_index': instance.currentVersionIndex,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'reasoning_content': instance.reasoningContent,
      'files': instance.files,
      'tool_call': instance.toolCall,
    };

const _$ChatRoleEnumMap = {
  ChatRole.user: 'user',
  ChatRole.model: 'model',
  ChatRole.system: 'system',
  ChatRole.tool: 'tool',
  ChatRole.developer: 'developer',
};
