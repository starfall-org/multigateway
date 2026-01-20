// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatProfile _$ChatProfileFromJson(Map<String, dynamic> json) => ChatProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      config: LlmChatConfig.fromJson(json['config'] as Map<String, dynamic>),
      activeMcp: (json['active_mcp'] as List<dynamic>?)
              ?.map((e) => ActiveMcp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeModelTools: (json['active_model_tools'] as List<dynamic>?)
              ?.map((e) => ModelTool.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChatProfileToJson(ChatProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'config': instance.config.toJson(),
      'active_mcp': instance.activeMcp.map((e) => e.toJson()).toList(),
      'active_model_tools':
          instance.activeModelTools.map((e) => e.toJson()).toList(),
    };

LlmChatConfig _$LlmChatConfigFromJson(Map<String, dynamic> json) =>
    LlmChatConfig(
      systemPrompt: json['system_prompt'] as String,
      enableStream: json['enable_stream'] as bool,
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: (json['top_k'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      contextWindow: (json['context_window'] as num?)?.toInt() ?? 60000,
      conversationLength: (json['conversation_length'] as num?)?.toInt() ?? 10,
      maxTokens: (json['max_tokens'] as num?)?.toInt() ?? 4000,
      customThinkingTokens: (json['custom_thinking_tokens'] as num?)?.toInt(),
      thinkingLevel:
          $enumDecodeNullable(_$ThinkingLevelEnumMap, json['thinking_level']) ??
              ThinkingLevel.auto,
    );

Map<String, dynamic> _$LlmChatConfigToJson(LlmChatConfig instance) =>
    <String, dynamic>{
      'system_prompt': instance.systemPrompt,
      'enable_stream': instance.enableStream,
      'top_p': instance.topP,
      'top_k': instance.topK,
      'temperature': instance.temperature,
      'context_window': instance.contextWindow,
      'conversation_length': instance.conversationLength,
      'max_tokens': instance.maxTokens,
      'custom_thinking_tokens': instance.customThinkingTokens,
      'thinking_level': _$ThinkingLevelEnumMap[instance.thinkingLevel]!,
    };

const _$ThinkingLevelEnumMap = {
  ThinkingLevel.none: 'none',
  ThinkingLevel.low: 'low',
  ThinkingLevel.medium: 'medium',
  ThinkingLevel.high: 'high',
  ThinkingLevel.auto: 'auto',
  ThinkingLevel.custom: 'custom',
};

ActiveMcp _$ActiveMcpFromJson(Map<String, dynamic> json) => ActiveMcp(
      id: json['id'] as String,
      activeToolNames: (json['active_tool_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ActiveMcpToJson(ActiveMcp instance) => <String, dynamic>{
      'id': instance.id,
      'active_tool_names': instance.activeToolNames,
    };

ModelTool _$ModelToolFromJson(Map<String, dynamic> json) => ModelTool(
      modelId: json['model_id'] as String,
      providerId: json['provider_id'] as String,
      toolName: json['tool_name'] as String,
    );

Map<String, dynamic> _$ModelToolToJson(ModelTool instance) => <String, dynamic>{
      'model_id': instance.modelId,
      'provider_id': instance.providerId,
      'tool_name': instance.toolName,
    };
