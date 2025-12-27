import 'dart:convert';

import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final int? tokenCount;
  final bool isAgentConversation;

  // Optional persisted selections per conversation
  final String? providerName;
  final String? modelName;
  final List<String>? enabledToolNames; // Persisted MCP tool names

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.tokenCount,
    this.isAgentConversation = false,
    this.providerName,
    this.modelName,
    this.enabledToolNames,
  });

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    int? tokenCount,
    bool? isAgentConversation,
    String? providerName,
    String? modelName,
    List<String>? enabledToolNames,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      tokenCount: tokenCount ?? this.tokenCount,
      isAgentConversation: isAgentConversation ?? this.isAgentConversation,
      providerName: providerName ?? this.providerName,
      modelName: modelName ?? this.modelName,
      enabledToolNames: enabledToolNames ?? this.enabledToolNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'tokenCount': tokenCount,
      'isAgentConversation': isAgentConversation,
      if (providerName != null) 'providerName': providerName,
      if (modelName != null) 'modelName': modelName,
      if (enabledToolNames != null) 'enabledToolNames': enabledToolNames,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e))
              .toList() ??
          [],
      tokenCount: json['tokenCount'] as int?,
      isAgentConversation: json['isAgentConversation'] == true,
      providerName: json['providerName'] as String?,
      modelName: json['modelName'] as String?,
      enabledToolNames: (json['enabledToolNames'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  String toJsonString() => json.encode(toJson());

  factory Conversation.fromJsonString(String jsonString) =>
      Conversation.fromJson(json.decode(jsonString));
}
