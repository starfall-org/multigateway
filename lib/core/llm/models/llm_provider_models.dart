import 'package:json_annotation/json_annotation.dart';

part 'llm_provider_models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmProviderModels {
  final String id;
  List<LlmModel?> models;

  LlmProviderModels({required this.id, required this.models});

  factory LlmProviderModels.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderModelsFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderModelsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmModel {
  final String id;
  final String displayName;
  final LlmModelType type;
  final String? icon;
  final String? providerName;
  final Map<String, dynamic>? metadata;

  LlmModel({
    required this.id,
    required this.displayName,
    required this.type,
    this.icon,
    this.providerName,
    this.metadata,
  });

  factory LlmModel.fromJson(Map<String, dynamic> json) =>
      _$LlmModelFromJson(json);

  Map<String, dynamic> toJson() => _$LlmModelToJson(this);
}

enum LlmModelType { chat, image, audio, video, embed, media, other }
