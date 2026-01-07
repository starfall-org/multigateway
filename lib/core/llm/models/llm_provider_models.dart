import 'package:json_annotation/json_annotation.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/core/llm/models/legacy_llm_model.dart';

part 'llm_provider_models.g.dart';

@JsonSerializable()
class LlmProviderModels {
  final String id;
  List<BasicModel?> basicModels;
  List<OllamaModel?> ollamaModels;
  List<GoogleAiModel?> googleAiModels;
  List<GitHubModel?> githubModels;

  LlmProviderModels({
    required this.id,
    required this.basicModels,
    required this.ollamaModels,
    required this.googleAiModels,
    required this.githubModels,
  });

  List<LegacyAiModel> toAiModels() {
    final List<LegacyAiModel> models = [];

    for (var m in basicModels) {
      if (m != null) {
        models.add(
          LegacyAiModel(
            name: m.id,
            displayName: m.displayName,
            type: ModelType.chat,
          ),
        );
      }
    }

    for (var m in ollamaModels) {
      if (m != null) {
        models.add(
          LegacyAiModel(
            name: m.model,
            displayName: m.name,
            type: ModelType.chat,
          ),
        );
      }
    }

    for (var m in googleAiModels) {
      if (m != null) {
        models.add(
          LegacyAiModel(
            name: m.name,
            displayName: m.displayName,
            type: ModelType.chat,
          ),
        );
      }
    }

    for (var m in githubModels) {
      if (m != null) {
        models.add(
          LegacyAiModel(name: m.id, displayName: m.name, type: ModelType.chat),
        );
      }
    }

    return models;
  }

  factory LlmProviderModels.fromJson(Map<String, dynamic> json) =>
      _$LlmProviderModelsFromJson(json);

  Map<String, dynamic> toJson() => _$LlmProviderModelsToJson(this);
}
