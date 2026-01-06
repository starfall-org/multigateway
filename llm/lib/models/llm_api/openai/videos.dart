import 'package:json_annotation/json_annotation.dart';

part 'videos.g.dart';

// Request Models
@JsonSerializable()
class OpenAiVideosRequest {
  final String prompt;
  final String? model;
  final String? seconds;
  final String? size;
  final String? inputReference;

  OpenAiVideosRequest({
    required this.prompt,
    this.model = 'sora-2',
    this.seconds = '4',
    this.size = '720x1280',
    this.inputReference,
  });

  factory OpenAiVideosRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiVideosRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiVideosRequestToJson(this);
}

// Response Models
@JsonSerializable()
class OpenAiVideos {
  final String id;
  final String object;
  final String model;
  final String status;
  final double progress;
  final int createdAt;
  final String size;
  final String seconds;
  final String quality;
  final VideoError? error;

  OpenAiVideos({
    required this.id,
    required this.object,
    required this.model,
    required this.status,
    required this.progress,
    required this.createdAt,
    required this.size,
    required this.seconds,
    required this.quality,
    this.error,
  });

  factory OpenAiVideos.fromJson(Map<String, dynamic> json) =>
      _$OpenAiVideosFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiVideosToJson(this);
}

@JsonSerializable()
class VideoError {
  final String code;
  final String message;

  VideoError({required this.code, required this.message});

  factory VideoError.fromJson(Map<String, dynamic> json) =>
      _$VideoErrorFromJson(json);

  Map<String, dynamic> toJson() => _$VideoErrorToJson(this);
}

// Model enum values for type safety
class OpenAiVideoModels {
  static const String sora2 = 'sora-2';
  static const String sora2Pro = 'sora-2-pro';
}

class OpenAiVideoSizes {
  static const String portrait720 = '720x1280';
  static const String landscape720 = '1280x720';
  static const String portrait1024 = '1024x1792';
  static const String landscape1024 = '1792x1024';
}

class OpenAiVideoDurations {
  static const String fourSeconds = '4';
  static const String eightSeconds = '8';
  static const String twelveSeconds = '12';
}

class OpenAiVideoStatus {
  static const String queued = 'queued';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';
}

class OpenAiVideoQuality {
  static const String standard = 'standard';
  static const String hd = 'hd';
}
