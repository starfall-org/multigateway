import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

enum ThinkingLevel { none, low, medium, high, auto, custom }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AIProfile {
  final String id;
  final String name;
  final String? icon;
  final AiConfig config;
  final bool profileConversations;
  final List<String?> conversationIds;
  final List<ActiveMCPServer> activeMCPServers;
  final List<String> activeBuiltInTools;
  final bool? persistChatSelection;

  AIProfile({
    required this.id,
    required this.name,
    this.icon,
    required this.config,
    this.profileConversations = false,
    this.conversationIds = const [],
    this.activeMCPServers = const [],
    this.activeBuiltInTools = const [],
    this.persistChatSelection,
  });

  List<String> get activeMCPServerIds =>
      activeMCPServers.map((e) => e.id).toList();

  factory AIProfile.fromJson(Map<String, dynamic> json) =>
      _$AIProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AIProfileToJson(this);

  String toJsonString() => json.encode(toJson());

  factory AIProfile.fromJsonString(String jsonString) =>
      AIProfile.fromJson(json.decode(jsonString));
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AiConfig {
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

  AiConfig({
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

  factory AiConfig.fromJson(Map<String, dynamic> json) =>
      _$AiConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AiConfigToJson(this);
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
