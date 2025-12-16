import 'package:ai_gateway/core/storage/provider_repository.dart';
import 'package:ai_gateway/core/models/agent.dart';
import 'package:ai_gateway/core/models/chat/chat_message.dart';
import 'package:ai_gateway/features/mcp/models/mcp_llm_wrapper.dart';
import 'package:ai_gateway/core/models/provider.dart';

class ChatService {
  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required Agent agent,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      return 'No provider configured. Please add a provider in Settings > Providers.';
    }

    // Prefer Anthropic if available, otherwise prefer OpenAI
    LLMProvider provider = providers.first;
    final anthropic = providers.where((p) => p.type == ProviderType.anthropic);
    if (anthropic.isNotEmpty) {
      provider = anthropic.first;
    } else {
      final openai = providers.where((p) => p.type == ProviderType.openai);
      if (openai.isNotEmpty) {
        provider = openai.first;
      }
    }

    // Use MCP LLM Wrapper for unified API
    try {
      // Add current user message to history for the wrapper
      final messagesWithCurrent = [
        ...history,
        ChatMessage(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.user,
          content: userText,
          timestamp: DateTime.now(),
        ),
      ];

      return await McpLlmWrapper.generateCompletion(
        provider: provider,
        messages: messagesWithCurrent,
        agent: agent,
        temperature: agent.temperature,
      );
    } catch (e) {
      return 'Failed to generate response: $e';
    }
  }
}
