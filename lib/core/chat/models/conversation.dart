import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:multigateway/core/chat/models/message.dart';

part 'conversation.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;
  final int? tokenCount;
  final String providerId;
  final String modelName;
  final String profileId;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.tokenCount,
    required this.providerId,
    required this.modelName,
    required this.profileId,
  });

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    int? tokenCount,
    bool? isAgentConversation,
    String? providerId,
    String? modelName,
    String? profileId,
  }) {
    return Conversation(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      tokenCount: tokenCount ?? this.tokenCount,
      providerId: providerId ?? this.providerId,
      modelName: modelName ?? this.modelName,
      profileId: profileId ?? this.profileId,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  String toJsonString() => json.encode(toJson());

  factory Conversation.fromJsonString(String jsonString) =>
      Conversation.fromJson(json.decode(jsonString));
}
