import 'package:multigateway/core/llm/models/llm_provider_info.dart';

class ModelToolOption {
  final String name;
  final String title;
  final String description;

  const ModelToolOption({
    required this.name,
    required this.title,
    required this.description,
  });
}

String normalizeToolName(String value) {
  return value.toLowerCase().replaceAll('_', '');
}

bool toolNameMatches(String a, String b) {
  return normalizeToolName(a) == normalizeToolName(b);
}

const List<ModelToolOption> _openAiTools = [
  ModelToolOption(
    name: 'webSearch',
    title: 'Web Search',
    description: 'Search the web from the model.',
  ),
  ModelToolOption(
    name: 'fileSearch',
    title: 'File Search',
    description: 'Search uploaded files or vector stores.',
  ),
  ModelToolOption(
    name: 'imageGeneration',
    title: 'Image Generation',
    description: 'Generate images from text prompts.',
  ),
  ModelToolOption(
    name: 'codeInterpreter',
    title: 'Code Interpreter',
    description: 'Run code in a sandboxed environment.',
  ),
];

const List<ModelToolOption> _googleTools = [
  ModelToolOption(
    name: 'codeExecution',
    title: 'Code Execution',
    description: 'Run code in a sandboxed environment.',
  ),
  ModelToolOption(
    name: 'googleSearch',
    title: 'Google Search',
    description: 'Ground responses with Google Search.',
  ),
];

const List<ModelToolOption> _anthropicTools = [
  ModelToolOption(
    name: 'codeInterpreter',
    title: 'Code Execution',
    description: 'Run code in a sandboxed environment.',
  ),
  ModelToolOption(
    name: 'webSearch',
    title: 'Web Search',
    description: 'Search the web from the model.',
  ),
  ModelToolOption(
    name: 'webFetch',
    title: 'Web Fetch',
    description: 'Fetch and extract content from URLs.',
  ),
];

List<ModelToolOption> modelToolsForProvider(LlmProviderInfo provider) {
  switch (provider.type) {
    case ProviderType.openai:
      return provider.config.responsesApi ? _openAiTools : const [];
    case ProviderType.google:
      return _googleTools;
    case ProviderType.anthropic:
      return _anthropicTools;
    case ProviderType.ollama:
      return const [];
  }
}
