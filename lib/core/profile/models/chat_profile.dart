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
  final List<ActiveMcpServer> activeMcpServers;

  ChatProfile({
    required this.id,
    required this.name,
    this.icon,
    required this.config,
    this.activeMcpServers = const [],
  });

  List<String> get activeMcpServerIds =>
      activeMcpServers.map((e) => e.id).toList();

  factory ChatProfile.fromJson(Map<String, dynamic> json) =>
      _$ChatProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ChatProfileToJson(this);

  String toJsonString() => json.encode(toJson());

  factory ChatProfile.fromJsonString(String jsonString) =>
      ChatProfile.fromJson(json.decode(jsonString));
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
class ActiveMcpServer {
  final String id;
  final List<String> activeToolIds;

  ActiveMcpServer({required this.id, required this.activeToolIds});

  factory ActiveMcpServer.fromJson(Map<String, dynamic> json) =>
      _$ActiveMcpServerFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveMcpServerToJson(this);
}
