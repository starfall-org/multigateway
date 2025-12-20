import 'ai_model.dart';

class DefaultModels {
  final AIModel? titleGenerationModel; // text generation model
  final AIModel? chatSummarizationModel; // text generation model
  final AIModel? supportOCRModel; // text generation (OCR) model
  final AIModel? embeddingModel; // embedding model
  final AIModel? imageGenerationModel; // image generation model
  final AIModel?
  chatModel; // text generation/image generation/video generation model

  DefaultModels({
    this.titleGenerationModel,
    this.chatSummarizationModel,
    this.supportOCRModel,
    this.embeddingModel,
    this.imageGenerationModel,
    this.chatModel,
  });

  DefaultModels copyWith({
    AIModel? titleGenerationModel,
    AIModel? chatSummarizationModel,
    AIModel? supportOCRModel,
    AIModel? embeddingModel,
    AIModel? imageGenerationModel,
    AIModel? chatModel,
  }) {
    return DefaultModels(
      titleGenerationModel: titleGenerationModel ?? this.titleGenerationModel,
      chatSummarizationModel:
          chatSummarizationModel ?? this.chatSummarizationModel,
      supportOCRModel: supportOCRModel ?? this.supportOCRModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      imageGenerationModel: imageGenerationModel ?? this.imageGenerationModel,
      chatModel: chatModel ?? this.chatModel,
    );
  }

  factory DefaultModels.fromJson(Map<String, dynamic> json) {
    return DefaultModels(
      titleGenerationModel: json['titleGenerationModel'] != null
          ? AIModel.fromJson(json['titleGenerationModel'])
          : null,
      chatSummarizationModel: json['chatSummarizationModel'] != null
          ? AIModel.fromJson(json['chatSummarizationModel'])
          : null,
      supportOCRModel: json['supportOCRModel'] != null
          ? AIModel.fromJson(json['supportOCRModel'])
          : null,
      embeddingModel: json['embeddingModel'] != null
          ? AIModel.fromJson(json['embeddingModel'])
          : null,
      imageGenerationModel: json['imageGenerationModel'] != null
          ? AIModel.fromJson(json['imageGenerationModel'])
          : null,
      chatModel: json['chatModel'] != null
          ? AIModel.fromJson(json['chatModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleGenerationModel': titleGenerationModel?.toJson(),
      'chatSummarizationModel': chatSummarizationModel?.toJson(),
      'supportOCRModel': supportOCRModel?.toJson(),
      'embeddingModel': embeddingModel?.toJson(),
      'imageGenerationModel': imageGenerationModel?.toJson(),
      'chatModel': chatModel?.toJson(),
    };
  }
}
