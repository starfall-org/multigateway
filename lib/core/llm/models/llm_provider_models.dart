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
  final String? icon;
  final String providerId;
  final Capabilities inputCapabilities;
  final Capabilities outputCapabilities;
  final Map<String, dynamic> modelInfo;

  LlmModel({
    required this.id,
    required this.displayName,
    this.icon,
    required this.providerId,
    required this.inputCapabilities,
    required this.outputCapabilities,
    required this.modelInfo,
  });

  factory LlmModel.fromJson(Map<String, dynamic> json) =>
      _$LlmModelFromJson(json);

  Map<String, dynamic> toJson() => _$LlmModelToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Capabilities {
  final bool text;
  final bool image;
  final bool video;
  final bool embed;
  final bool audio;
  final String? others;

  Capabilities({
    this.text = true,
    this.image = false,
    this.video = false,
    this.embed = false,
    this.audio = false,
    this.others,
  });

  factory Capabilities.fromJson(Map<String, dynamic> json) =>
      _$CapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$CapabilitiesToJson(this);
}
