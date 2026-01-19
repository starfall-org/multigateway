import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'chat_profile.g.dart';

enum ThinkingLevel { none, low, medium, high, auto, custom }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ChatProfile {
  final String id;
  final String name;
  final String? icon;
  final LlmChatConfig config;
  final List<ActiveMcp> activeMcp;
  final List<ModelTool> activeModelTools;

  ChatProfile({
    required this.id,
    required this.name,
    this.icon,
    required this.config,
    this.activeMcp = const [],
    this.activeModelTools = const [],
  });

  List<String> get activeMcpName => activeMcp.map((e) => e.id).toList();

  ChatProfile copyWith({
    String? id,
    String? name,
    String? icon,
    LlmChatConfig? config,
    List<ActiveMcp>? activeMcp,
    List<ModelTool>? activeModelTools,
  }) {
    return ChatProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      config: config ?? this.config,
      activeMcp: activeMcp ?? this.activeMcp,
      activeModelTools: activeModelTools ?? this.activeModelTools,
    );
  }

  factory ChatProfile.fromJson(Map<String, dynamic> json) =>
      _$ChatProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ChatProfileToJson(this);

  String toJsonString() => json.encode(toJson());

  factory ChatProfile.fromJsonString(String jsonString) =>
      ChatProfile.fromJson(json.decode(jsonString));
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmChatConfig {
  final String systemPrompt;
  final bool enableStream;
  final double? topP;
  final double? topK;
  final double? temperature;
  final int contextWindow;
  final int conversationLength;
  final int maxTokens;
  final int? customThinkingTokens;
  final ThinkingLevel thinkingLevel;

  LlmChatConfig({
    required this.systemPrompt,
    required this.enableStream,
    this.topP,
    this.topK,
    this.temperature,
    this.contextWindow = 60000,
    this.conversationLength = 10,
    this.maxTokens = 4000,
    this.customThinkingTokens,
    this.thinkingLevel = ThinkingLevel.auto,
  });

  factory LlmChatConfig.fromJson(Map<String, dynamic> json) =>
      _$LlmChatConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LlmChatConfigToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ActiveMcp {
  final String id;
  final List<String> activeToolNames;

  ActiveMcp({required this.id, required this.activeToolNames});

  factory ActiveMcp.fromJson(Map<String, dynamic> json) =>
      _$ActiveMcpFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveMcpToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ModelTool {
  final String modelId;
  final String providerId;
  final String toolName;

  ModelTool({
    required this.modelId,
    required this.providerId,
    required this.toolName,
  });

  factory ModelTool.fromJson(Map<String, dynamic> json) =>
      _$ModelToolFromJson(json);

  Map<String, dynamic> toJson() => _$ModelToolToJson(this);
}
