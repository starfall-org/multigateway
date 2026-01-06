// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnthropicModels _$AnthropicModelsFromJson(Map<String, dynamic> json) =>
    AnthropicModels(
      data: (json['data'] as List<dynamic>)
          .map((e) => BasicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String,
      hasMore: json['has_more'] as bool,
      lastId: json['last_id'] as String,
    );

Map<String, dynamic> _$AnthropicModelsToJson(AnthropicModels instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'first_id': instance.firstId,
      'has_more': instance.hasMore,
      'last_id': instance.lastId,
    };
