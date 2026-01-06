// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiModels _$OpenAiModelsFromJson(Map<String, dynamic> json) => OpenAiModels(
  object: json['object'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => BasicModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenAiModelsToJson(OpenAiModels instance) =>
    <String, dynamic>{'object': instance.object, 'data': instance.data};
