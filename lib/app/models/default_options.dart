import 'package:json_annotation/json_annotation.dart';

part 'default_options.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class DefaultOptions {
  final DefaultModels defaultModels;
  final String defaultProfileId;

  const DefaultOptions({
    required this.defaultModels,
    required this.defaultProfileId,
  });

  factory DefaultOptions.fromJson(Map<String, dynamic> json) =>
      _$DefaultOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultOptionsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class DefaultModels {
  final DefaultModel? titleGenerationModel;
  final DefaultModel? chatSummarizationModel;
  final DefaultModel? translationModel;
  final DefaultModel? supportOcrModel;
  final DefaultModel? embeddingModel;
  final DefaultModel? imageGenerationModel;
  final DefaultModel? chatModel;
  final DefaultModel? audioGenerationModel;
  final DefaultModel? videoGenerationModel;
  final DefaultModel? rerankModel;

  DefaultModels({
    this.titleGenerationModel,
    this.chatSummarizationModel,
    this.translationModel,
    this.supportOcrModel,
    this.embeddingModel,
    this.imageGenerationModel,
    this.chatModel,
    this.audioGenerationModel,
    this.videoGenerationModel,
    this.rerankModel,
  });

  DefaultModels copyWith({
    DefaultModel? titleGenerationModel,
    DefaultModel? chatSummarizationModel,
    DefaultModel? translationModel,
    DefaultModel? supportOcrModel,
    DefaultModel? embeddingModel,
    DefaultModel? imageGenerationModel,
    DefaultModel? chatModel,
    DefaultModel? audioGenerationModel,
    DefaultModel? videoGenerationModel,
    DefaultModel? rerankModel,
  }) {
    return DefaultModels(
      titleGenerationModel: titleGenerationModel ?? this.titleGenerationModel,
      chatSummarizationModel:
          chatSummarizationModel ?? this.chatSummarizationModel,
      supportOcrModel: supportOcrModel ?? this.supportOcrModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      imageGenerationModel: imageGenerationModel ?? this.imageGenerationModel,
      chatModel: chatModel ?? this.chatModel,
      audioGenerationModel: audioGenerationModel ?? this.audioGenerationModel,
      videoGenerationModel: videoGenerationModel ?? this.videoGenerationModel,
      rerankModel: rerankModel ?? this.rerankModel,
    );
  }

  factory DefaultModels.fromJson(Map<String, dynamic> json) =>
      _$DefaultModelsFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultModelsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class DefaultModel {
  final String modelId;
  final String providerId;

  DefaultModel({required this.modelId, required this.providerId});

  factory DefaultModel.fromJson(Map<String, dynamic> json) =>
      _$DefaultModelFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultModelToJson(this);
}
