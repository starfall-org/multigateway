import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:multigateway/features/home/domain/models/message.dart';

part 'conversation.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final int? tokenCount;
  final bool isAgentConversation;
  final String? providerName;
  final String? modelName;
  final List<String>? enabledToolNames;

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

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  String toJsonString() => json.encode(toJson());

  factory Conversation.fromJsonString(String jsonString) =>
      Conversation.fromJson(json.decode(jsonString));
}
