import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

enum ThinkingLevel { none, low, medium, high, auto, custom }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmChatProfile {
  final String id;
  final String name;
  final String? icon;
  final LlmChatConfig config;
  final List<ActiveMCPServer> activeMCPServers;

  LlmChatProfile({
    required this.id,
    required this.name,
    this.icon,
    required this.config,
    this.activeMCPServers = const [],
  });

  List<String> get activeMCPServerIds =>
      activeMCPServers.map((e) => e.id).toList();

  factory LlmChatProfile.fromJson(Map<String, dynamic> json) =>
      _$LlmChatProfileFromJson(json);

  Map<String, dynamic> toJson() => _$LlmChatProfileToJson(this);

  String toJsonString() => json.encode(toJson());

  factory LlmChatProfile.fromJsonString(String jsonString) =>
      LlmChatProfile.fromJson(json.decode(jsonString));
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

@JsonSerializable(fieldRename: FieldRename.snake)
class ActiveMCPServer {
  final String id;
  final List<String> activeToolIds;

  ActiveMCPServer({required this.id, required this.activeToolIds});

  factory ActiveMCPServer.fromJson(Map<String, dynamic> json) =>
      _$ActiveMCPServerFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveMCPServerToJson(this);
}
