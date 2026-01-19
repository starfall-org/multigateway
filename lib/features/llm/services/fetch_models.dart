import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';

Capabilities _mapKind(Set<ModelKind> kinds) {
  if (kinds.contains(ModelKind.media)) {
    return Capabilities(text: true, image: true, video: true);
  }
  if (kinds.contains(ModelKind.image)) {
    return Capabilities(text: true, image: true);
  }
  if (kinds.contains(ModelKind.audio) || kinds.contains(ModelKind.tts)) {
    return Capabilities(text: true, audio: true);
  }
  if (kinds.contains(ModelKind.embeddings)) {
    return Capabilities(embed: true);
  }
  return Capabilities(text: true);
}

Map<String, dynamic> _mapInfo(ModelInfo info) {
  return {
    'model': info.model,
    'name': info.displayName,
    'description': info.description,
    'display_name': info.displayName,
    'extra': info.extra,
    'kinds': info.kinds.map((k) => k.name).toList(),
    'provider_name': info.providerName,
  };
}

LlmModel _fromModelInfo({
  required ModelInfo info,
  required String providerId,
}) {
  return LlmModel(
    id: info.name,
    displayName: info.displayName ?? info.name,
    inputCapabilities: _mapKind(info.kinds),
    outputCapabilities: _mapKind(info.kinds),
    providerId: providerId,
    modelInfo: _mapInfo(info),
  );
}

Future<List<LlmModel>> _collectModels(
  Stream<ModelInfo> stream, {
  required String providerId,
}) async {
  final models = <LlmModel>[];
  await for (final info in stream) {
    models.add(_fromModelInfo(info: info, providerId: providerId));
  }
  return models;
}

Future<List<LlmModel>> fetchModels({
  required LlmProviderInfo providerInfo,
}) async {
  final headers = <String, String>{};
  providerInfo.config.headers.forEach((key, value) {
    headers[key] = value.toString();
  });

  final auth = providerInfo.auth;
  final apiKey = auth.key;
  Uri? parseUri(String url) {
    if (url.isEmpty) return null;
    return Uri.tryParse(url);
  }

  if (auth.method == AuthMethod.customHeader) {
    final headerKey = auth.value ?? 'Authorization';
    if (apiKey != null) {
      headers[headerKey] = apiKey;
    }
  }

  switch (providerInfo.type) {
    case ProviderType.openai:
      if (providerInfo.config.responsesApi) {
        final provider = OpenAIResponsesProvider(
          apiKey: apiKey,
          baseUrl: parseUri(providerInfo.baseUrl),
          headers: headers,
        );
        return _collectModels(
          provider.listModels(),
          providerId: providerInfo.id,
        );
      }
      final provider = OpenAIProvider(
        apiKey: apiKey,
        baseUrl: parseUri(providerInfo.baseUrl),
        headers: headers,
      );
      return _collectModels(
        provider.listModels(),
        providerId: providerInfo.id,
      );
    case ProviderType.anthropic:
      final provider =
          AnthropicProvider(apiKey: apiKey, headers: headers);
      return _collectModels(
        provider.listModels(),
        providerId: providerInfo.id,
      );
    case ProviderType.ollama:
      final provider = OllamaProvider(
        baseUrl: parseUri(providerInfo.baseUrl),
        headers: headers,
      );
      return _collectModels(
        provider.listModels(),
        providerId: providerInfo.id,
      );
    case ProviderType.google:
      final provider = GoogleProvider(
        apiKey: apiKey,
        baseUrl: parseUri(providerInfo.baseUrl),
        headers: headers,
      );
      return _collectModels(
        provider.listModels(),
        providerId: providerInfo.id,
      );
  }
}
