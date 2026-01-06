import 'package:json_annotation/json_annotation.dart';

part 'image_generations.g.dart';

@JsonSerializable()
class OpenAiImagesGenerations {
  final int created;
  final List<ImageData> data;

  OpenAiImagesGenerations({required this.created, required this.data});

  factory OpenAiImagesGenerations.fromJson(Map<String, dynamic> json) =>
      _$OpenAiImagesGenerationsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiImagesGenerationsToJson(this);
}

@JsonSerializable()
class ImageData {
  final String? b64Json;
  final String? url;
  final String? revisedPrompt;

  ImageData({this.b64Json, this.url, this.revisedPrompt});

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}

@JsonSerializable()
class OpenAiImagesGenerationsRequest {
  final String prompt;
  final String model;
  final int? n;
  final String? size;
  final String? quality;
  final String? responseFormat;
  final String? style;
  final String? user;

  OpenAiImagesGenerationsRequest({
    required this.prompt,
    required this.model,
    this.n,
    this.size,
    this.quality,
    this.responseFormat,
    this.style,
    this.user,
  });

  factory OpenAiImagesGenerationsRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiImagesGenerationsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiImagesGenerationsRequestToJson(this);
}
