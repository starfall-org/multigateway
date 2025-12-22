import 'ai_model.dart';


class DefaultOptions {
  final DefaultModels defaultModels;
  final AIProfile profile;
}

class DefaultModels {
  final AIModel? titleGenerationModel; // text generation model
  final AIModel? chatSummarizationModel; // text generation model
  final AIModel? translationModel; // text generation model
  final AIModel? supportOCRModel; // text generation (OCR) model
  final AIModel? embeddingModel; // embedding model
  final AIModel? imageGenerationModel; // image generation model
  final AIModel?
  chatModel; // text generation/image generation/video generation model
  final AIModel? audioGenerationModel; // audio generation model
  final AIModel? videoGenerationModel; // video generation model
  final AIModel? rerankModel; // rerank model

  DefaultModels({
    this.titleGenerationModel,
    this.chatSummarizationModel,
    this.translationModel,
    this.supportOCRModel,
    this.embeddingModel,
    this.imageGenerationModel,
    this.chatModel,
    this.audioGenerationModel,
    this.videoGenerationModel,
    this.rerankModel,
  });

  DefaultModels copyWith({
    AIModel? titleGenerationModel,
    AIModel? chatSummarizationModel,
    AIModel? translationModel,
    AIModel? supportOCRModel,
    AIModel? embeddingModel,
    AIModel? imageGenerationModel,
    AIModel? chatModel,
    AIModel? audioGenerationModel,
    AIModel? videoGenerationModel,
    AIModel? rerankModel,
  }) {
    return DefaultModels(
      titleGenerationModel: titleGenerationModel ?? this.titleGenerationModel,
      chatSummarizationModel:
          chatSummarizationModel ?? this.chatSummarizationModel,
      supportOCRModel: supportOCRModel ?? this.supportOCRModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      imageGenerationModel: imageGenerationModel ?? this.imageGenerationModel,
      chatModel: chatModel ?? this.chatModel,
      audioGenerationModel: audioGenerationModel ?? this.audioGenerationModel,
      videoGenerationModel: videoGenerationModel ?? this.videoGenerationModel,
      rerankModel: rerankModel ?? this.rerankModel,
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
      translationModel: json['translationModel'] != null
          ? AIModel.fromJson(json['translationModel'])
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
      audioGenerationModel: json['audioGenerationModel'] != null
          ? AIModel.fromJson(json['audioGenerationModel'])
          : null,
      videoGenerationModel: json['videoGenerationModel'] != null
          ? AIModel.fromJson(json['videoGenerationModel'])
          : null,
      rerankModel: json['rerankModel'] != null
          ? AIModel.fromJson(json['rerankModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleGenerationModel': titleGenerationModel?.toJson(),
      'chatSummarizationModel': chatSummarizationModel?.toJson(),
      'translationModel': translationModel?.toJson(),
      'supportOCRModel': supportOCRModel?.toJson(),
      'embeddingModel': embeddingModel?.toJson(),
      'imageGenerationModel': imageGenerationModel?.toJson(),
      'chatModel': chatModel?.toJson(),
      'audioGenerationModel': audioGenerationModel?.toJson(),
      'videoGenerationModel': videoGenerationModel?.toJson(),
      'rerankModel': rerankModel?.toJson(),
    };
  }
}


