import 'package:llm/models/llm_api/ollama/tags.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/provider/anthropic/anthropic.dart';
import 'package:llm/provider/googleai/aistudio.dart';
import 'package:llm/provider/ollama/ollama.dart';
import 'package:llm/provider/openai/openai.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';

/// Fetch models cho OpenAI provider
Future<List<BasicModel>> fetchOpenLegacyAiModels({
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  final provider = OpenAiProvider(
    baseUrl: baseUrl,
    apiKey: apiKey ?? '',
    headers: customHeaders ?? {},
  );

  final response = await provider.listModels();
  return response.data;
}

/// Fetch models cho GitHub Models provider
Future<List<GitHubModel>> fetchGitHubModels({
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  final provider = OpenAiProvider(
    baseUrl: baseUrl,
    apiKey: apiKey ?? '',
    headers: customHeaders ?? {},
  );

  final models = await provider.gitHubCatalogModels();
  return models;
}

/// Fetch models cho Anthropic provider
Future<List<BasicModel>> fetchAnthropicModels({
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  final provider = AnthropicProvider(
    baseUrl: baseUrl,
    apiKey: apiKey ?? '',
    headers: customHeaders ?? {},
  );

  final response = await provider.listModels();
  return response.data;
}

/// Fetch models cho Ollama provider
Future<List<OllamaModel>> fetchOllamaModels({
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  final provider = OllamaProvider(
    baseUrl: baseUrl,
    headers: customHeaders ?? {},
  );

  final response = await provider.listModels();
  return response.models;
}

/// Fetch models cho Google AI provider
Future<List<GoogleAiModel>> fetchGoogleLegacyAiModels({
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  final provider = GoogleAiStudio(
    baseUrl: baseUrl,
    apiKey: apiKey ?? '',
    headers: customHeaders ?? {},
  );

  final response = await provider.listModels();

  if (response.models == null || response.models!.isEmpty) {
    return [];
  }

  // Convert GeminiModel to GoogleAiModel
  return response.models!.map((geminiModel) {
    return GoogleAiModel(
      name: geminiModel.name ?? 'unknown',
      displayName: geminiModel.displayName ?? 'Unknown Model',
      inputTokenLimit: 32000, // Default value
      outputTokenLimit: 8192, // Default value
      supportedGenerationMethods: ['generateContent'], // Default
      thinking: false,
      temperature: 1.0,
      maxTemperature: 2.0,
      topP: 0.95,
      topK: 40,
    );
  }).toList();
}

/// Main function để fetch models dựa trên provider type
/// Returns dynamic type vì mỗi provider có model type khác nhau
/// Special case: If baseUrl contains 'https://models.github.ai', returns GitHubModel list
Future<List<dynamic>> fetchModels({
  required ProviderType providerType,
  required String baseUrl,
  String? apiKey,
  Map<String, String>? customHeaders,
}) async {
  // Special case: GitHub Models
  if (baseUrl.contains('https://models.github.ai')) {
    return fetchGitHubModels(
      baseUrl: baseUrl,
      apiKey: apiKey,
      customHeaders: customHeaders,
    );
  }

  // Regular providers
  switch (providerType) {
    case ProviderType.openai:
      return fetchOpenLegacyAiModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
        customHeaders: customHeaders,
      );
    case ProviderType.anthropic:
      return fetchAnthropicModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
        customHeaders: customHeaders,
      );
    case ProviderType.ollama:
      return fetchOllamaModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
        customHeaders: customHeaders,
      );
    case ProviderType.googleai:
      return fetchGoogleLegacyAiModels(
        baseUrl: baseUrl,
        apiKey: apiKey,
        customHeaders: customHeaders,
      );
  }
}
