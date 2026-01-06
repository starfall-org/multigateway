// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'videos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiVideosRequest _$OpenAiVideosRequestFromJson(Map<String, dynamic> json) =>
    OpenAiVideosRequest(
      prompt: json['prompt'] as String,
      model: json['model'] as String? ?? 'sora-2',
      seconds: json['seconds'] as String? ?? '4',
      size: json['size'] as String? ?? '720x1280',
      inputReference: json['inputReference'] as String?,
    );

Map<String, dynamic> _$OpenAiVideosRequestToJson(
  OpenAiVideosRequest instance,
) => <String, dynamic>{
  'prompt': instance.prompt,
  'model': instance.model,
  'seconds': instance.seconds,
  'size': instance.size,
  'inputReference': instance.inputReference,
};

OpenAiVideos _$OpenAiVideosFromJson(Map<String, dynamic> json) => OpenAiVideos(
  id: json['id'] as String,
  object: json['object'] as String,
  model: json['model'] as String,
  status: json['status'] as String,
  progress: (json['progress'] as num).toDouble(),
  createdAt: (json['createdAt'] as num).toInt(),
  size: json['size'] as String,
  seconds: json['seconds'] as String,
  quality: json['quality'] as String,
  error: json['error'] == null
      ? null
      : VideoError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenAiVideosToJson(OpenAiVideos instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'model': instance.model,
      'status': instance.status,
      'progress': instance.progress,
      'createdAt': instance.createdAt,
      'size': instance.size,
      'seconds': instance.seconds,
      'quality': instance.quality,
      'error': instance.error,
    };

VideoError _$VideoErrorFromJson(Map<String, dynamic> json) => VideoError(
  code: json['code'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$VideoErrorToJson(VideoError instance) =>
    <String, dynamic>{'code': instance.code, 'message': instance.message};
