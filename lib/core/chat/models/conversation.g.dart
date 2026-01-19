// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  title: json['title'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  tokenCount: (json['token_count'] as num?)?.toInt(),
  providerId: json['provider_id'] as String,
  modelId: json['model_name'] as String,
  profileId: json['profile_id'] as String,
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
      'token_count': instance.tokenCount,
      'provider_id': instance.providerId,
      'model_name': instance.modelId,
      'profile_id': instance.profileId,
    };
