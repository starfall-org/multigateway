// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OllamaTagsResponse _$OllamaTagsResponseFromJson(Map<String, dynamic> json) =>
    OllamaTagsResponse(
      models: (json['models'] as List<dynamic>)
          .map((e) => OllamaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OllamaTagsResponseToJson(OllamaTagsResponse instance) =>
    <String, dynamic>{'models': instance.models};

OllamaModel _$OllamaModelFromJson(Map<String, dynamic> json) => OllamaModel(
  name: json['name'] as String,
  modifiedAt: json['modifiedAt'] as String?,
  size: (json['size'] as num?)?.toInt(),
  details: json['details'] == null
      ? null
      : OllamaModelDetails.fromJson(json['details'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OllamaModelToJson(OllamaModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'modifiedAt': instance.modifiedAt,
      'size': instance.size,
      'details': instance.details,
    };

OllamaModelDetails _$OllamaModelDetailsFromJson(Map<String, dynamic> json) =>
    OllamaModelDetails(
      format: json['format'] as String?,
      family: json['family'] as String?,
      families: (json['families'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      parameterSize: json['parameterSize'] as String?,
      quantizationLevel: json['quantizationLevel'] as String?,
      parentId: json['parentId'] as String?,
    );

Map<String, dynamic> _$OllamaModelDetailsToJson(OllamaModelDetails instance) =>
    <String, dynamic>{
      'format': instance.format,
      'family': instance.family,
      'families': instance.families,
      'parameterSize': instance.parameterSize,
      'quantizationLevel': instance.quantizationLevel,
      'parentId': instance.parentId,
    };
