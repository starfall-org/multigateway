import 'package:json_annotation/json_annotation.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';

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

/// Enum to identify the origin model type for serialization
enum OriginModelType { basic, github, googleai, ollama }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LlmModel {
  final String id;
  final String? icon;
  final String displayName;
  final LlmModelType type;

  /// Stored origin type for deserialization
  final OriginModelType? originType;

  /// Stored origin data for deserialization
  final Map<String, dynamic>? originData;

  // Private field to cache the deserialized origin
  dynamic _cachedOrigin;

  LlmModel({
    required this.id,
    this.icon,
    required this.displayName,
    required this.type,
    dynamic origin,
    this.originType,
    this.originData,
  }) : _cachedOrigin = origin;

  /// Get the origin model (BasicModel, GitHubModel, GoogleAiModel, OllamaModel)
  /// Lazily deserializes from originType/originData if not already set
  dynamic get origin {
    if (_cachedOrigin != null) return _cachedOrigin;

    // Deserialize from originType and originData
    if (originType != null && originData != null) {
      switch (originType!) {
        case OriginModelType.basic:
          _cachedOrigin = BasicModel.fromJson(originData!);
          break;
        case OriginModelType.github:
          _cachedOrigin = GitHubModel.fromJson(originData!);
          break;
        case OriginModelType.googleai:
          _cachedOrigin = GoogleAiModel.fromJson(originData!);
          break;
        case OriginModelType.ollama:
          _cachedOrigin = OllamaModel.fromJson(originData!);
          break;
      }
    }
    return _cachedOrigin;
  }

  factory LlmModel.fromJson(Map<String, dynamic> json) =>
      _$LlmModelFromJson(json);

  Map<String, dynamic> toJson() {
    // Determine origin type and serialize origin data
    OriginModelType? oType = originType;
    Map<String, dynamic>? oData = originData;

    // If we have a cached origin but no originType/originData, serialize it
    if (_cachedOrigin != null && (oType == null || oData == null)) {
      if (_cachedOrigin is BasicModel) {
        oType = OriginModelType.basic;
        oData = (_cachedOrigin as BasicModel).toJson();
      } else if (_cachedOrigin is GitHubModel) {
        oType = OriginModelType.github;
        oData = (_cachedOrigin as GitHubModel).toJson();
      } else if (_cachedOrigin is GoogleAiModel) {
        oType = OriginModelType.googleai;
        oData = (_cachedOrigin as GoogleAiModel).toJson();
      } else if (_cachedOrigin is OllamaModel) {
        oType = OriginModelType.ollama;
        oData = (_cachedOrigin as OllamaModel).toJson();
      }
    }

    return {
      'id': id,
      'icon': icon,
      'display_name': displayName,
      'type': type.name,
      'origin_type': oType?.name,
      'origin_data': oData,
    };
  }
}

enum LlmModelType { chat, image, audio, video, embed }
