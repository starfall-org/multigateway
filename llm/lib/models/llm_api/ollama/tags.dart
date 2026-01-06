import 'package:json_annotation/json_annotation.dart';

part 'tags.g.dart';

/// Response model for Ollama /api/tags endpoint
@JsonSerializable()
class OllamaTagsResponse {
  final List<OllamaModel> models;

  OllamaTagsResponse({required this.models});

  factory OllamaTagsResponse.fromJson(Map<String, dynamic> json) =>
      _$OllamaTagsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaTagsResponseToJson(this);
}

/// Model information from Ollama tags response
@JsonSerializable()
class OllamaModel {
  final String name;
  final String? modifiedAt;
  final int? size;
  final OllamaModelDetails? details;

  OllamaModel({
    required this.name,
    this.modifiedAt,
    this.size,
    this.details,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) =>
      _$OllamaModelFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaModelToJson(this);
}

/// Detailed information about a model
@JsonSerializable()
class OllamaModelDetails {
  final String? format;
  final String? family;
  final List<String>? families;
  final String? parameterSize;
  final String? quantizationLevel;
  final String? parentId;

  OllamaModelDetails({
    this.format,
    this.family,
    this.families,
    this.parameterSize,
    this.quantizationLevel,
    this.parentId,
  });

  factory OllamaModelDetails.fromJson(Map<String, dynamic> json) =>
      _$OllamaModelDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$OllamaModelDetailsToJson(this);
}