// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_generations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiImagesGenerations _$OpenAiImagesGenerationsFromJson(
  Map<String, dynamic> json,
) => OpenAiImagesGenerations(
  created: (json['created'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => ImageData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OpenAiImagesGenerationsToJson(
  OpenAiImagesGenerations instance,
) => <String, dynamic>{'created': instance.created, 'data': instance.data};

ImageData _$ImageDataFromJson(Map<String, dynamic> json) => ImageData(
  b64Json: json['b64Json'] as String?,
  url: json['url'] as String?,
  revisedPrompt: json['revisedPrompt'] as String?,
);

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
  'b64Json': instance.b64Json,
  'url': instance.url,
  'revisedPrompt': instance.revisedPrompt,
};

OpenAiImagesGenerationsRequest _$OpenAiImagesGenerationsRequestFromJson(
  Map<String, dynamic> json,
) => OpenAiImagesGenerationsRequest(
  prompt: json['prompt'] as String,
  model: json['model'] as String,
  n: (json['n'] as num?)?.toInt(),
  size: json['size'] as String?,
  quality: json['quality'] as String?,
  responseFormat: json['responseFormat'] as String?,
  style: json['style'] as String?,
  user: json['user'] as String?,
);

Map<String, dynamic> _$OpenAiImagesGenerationsRequestToJson(
  OpenAiImagesGenerationsRequest instance,
) => <String, dynamic>{
  'prompt': instance.prompt,
  'model': instance.model,
  'n': instance.n,
  'size': instance.size,
  'quality': instance.quality,
  'responseFormat': instance.responseFormat,
  'style': instance.style,
  'user': instance.user,
};
