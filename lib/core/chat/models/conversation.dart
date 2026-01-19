import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>> messages;
  final int? tokenCount;
  final String providerId;
  final String modelId;
  final String profileId;

  String get modelName => modelId;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.tokenCount,
    required this.providerId,
    required this.modelId,
    required this.profileId,
  });

  Conversation copyWith({
    String? title,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? messages,
    int? tokenCount,
    String? providerId,
    String? modelId,
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
      modelId: modelId ?? this.modelId,
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
