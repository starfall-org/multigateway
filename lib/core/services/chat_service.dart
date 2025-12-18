import '../storage/provider_repository.dart';
import '../models/ai_agent.dart';
import '../models/chat/message.dart';
import '../models/provider.dart';
import '../models/ai/ai_dto.dart';
import 'ai/openai.dart';
import 'ai/anthropic.dart';
import 'ai/ollama.dart';

class ChatService {
  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final provider = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

    // Ensure model exists in provider (optional validation)
    // final model = provider.models.firstWhere(
    //   (m) => m.name == modelName,
    //   orElse: () => throw Exception('Model "$modelName" not found for provider.'),
    // );

    final messagesWithCurrent = [
      ...history,
      ChatMessage(
        id: 'temp-user',
        role: ChatRole.user,
        content: userText,
        timestamp: DateTime.now(),
      ),
    ];

    // Optional: MCP integration logic (placeholder)
    // try {
    //   final mcpRepository = await MCPRepository.init();
    //   final mcpServers = agent.activeMCPServerIds
    //       .map((id) => mcpRepository.getItem(id))
    //       .whereType<MCPServer>()
    //       .toList();
    //    TODO: attach tools from mcpServers
    // } catch (_) {}

    final systemInstruction = agent.systemPrompt;

    switch (provider.type) {
      case ProviderType.google:
        // Google AI service is not implemented yet
        throw UnimplementedError('Google AI is not implemented in this version.');

      case ProviderType.openai:
        final routes = provider.openAIRoutes;
        final service = OpenAI(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          chatPath: routes.chatCompletion,
          responsesPath: routes.responses,
          modelsPath: routes.models,
          embeddingsPath: routes.embeddings,
          imagesGenerationsPath: routes.imagesGenerations,
          imagesEditsPath: routes.imagesEdits,
          videosPath: routes.videos,
          audioSpeechPath: routes.audioSpeech,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        // Add system instruction as first message if present
        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            AIMessage(
              role: 'system',
              content: [AIContent(type: AIContentType.text, text: systemInstruction)],
            ),
          );
        }
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
        );
        
        final resp = await service.generate(aiRequest);
        return resp.text;

      case ProviderType.anthropic:
        final routes = provider.anthropicRoutes;
        final service = Anthropic(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          messagesPath: routes.messages,
          modelsPath: routes.models,
          anthropicVersion: routes.anthropicVersion,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          extra: systemInstruction.isNotEmpty ? {'system': systemInstruction} : {},
        );
        final resp = await service.generate(aiRequest);
        return resp.text;

      case ProviderType.ollama:
        final routes = provider.ollamaRoutes;
        final service = Ollama(
          baseUrl: provider.baseUrl ?? 'http://localhost:11434',
          apiKey: provider.apiKey,
          chatPath: routes.chat,
          tagsPath: routes.tags,
          embeddingsPath: routes.embeddings,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
        );
        final resp = await service.generate(aiRequest);
        return resp.text;
    }
  }
}
