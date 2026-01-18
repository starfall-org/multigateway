import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';

LlmModelType _mapKind(Set<ModelKind> kinds) {
  final kind = kinds.first;
  switch (kind) {
    case ModelKind.chat:
      return LlmModelType.chat;
    case ModelKind.image:
      return LlmModelType.image;
    case ModelKind.audio:
      return LlmModelType.audio;
    case ModelKind.embeddings:
      return LlmModelType.embed;
    case ModelKind.media:
      return LlmModelType.media;
    default:
      return LlmModelType.other;
  }
}

LlmModel _fromModelInfo(ModelInfo info) {
  return LlmModel(
    id: info.name,
    displayName: info.displayName ?? info.name,
    type: _mapKind(info.kinds),
    providerName: info.providerName,
    metadata: info.extra,
  );
}

Future<List<LlmModel>> _collectModels(Stream<ModelInfo> stream) async {
  final models = <LlmModel>[];
  await for (final info in stream) {
    models.add(_fromModelInfo(info));
  }
  return models;
}

Future<List<LlmModel>> fetchModels({
  required ProviderType providerType,
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  switch (providerType) {
    case ProviderType.openai:
      final provider = OpenAIProvider(
        apiKey: apiKey,
        baseUrl: Uri.tryParse(baseUrl),
        headers: customHeaders,
      );
      return _collectModels(provider.listModels());
    case ProviderType.anthropic:
      final provider = AnthropicProvider(
        apiKey: apiKey,
        headers: customHeaders,
      );
      return _collectModels(provider.listModels());
    case ProviderType.ollama:
      final provider = OllamaProvider(
        baseUrl: Uri.tryParse(baseUrl),
        headers: customHeaders,
      );
      return _collectModels(provider.listModels());
    case ProviderType.googleai:
      final provider = GoogleProvider(
        apiKey: apiKey,
        baseUrl: Uri.tryParse(baseUrl),
        headers: customHeaders,
      );
      return _collectModels(provider.listModels());
  }
}
