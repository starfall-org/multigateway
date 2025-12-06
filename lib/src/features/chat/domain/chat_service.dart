import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lmhub/src/core/storage/provider_repository.dart';
import 'package:lmhub/src/features/settings/domain/provider.dart';
import 'package:lmhub/src/features/agents/domain/agent.dart';
import 'package:lmhub/src/features/chat/domain/chat_models.dart';

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

    // Prefer OpenAI if available, otherwise take the first provider
    LLMProvider provider = providers.first;
    final openai = providers.where((p) => p.type == ProviderType.openai);
    if (openai.isNotEmpty) {
      provider = openai.first;
    }

    switch (provider.type) {
      case ProviderType.openai:
        return await _callOpenAI(provider, userText, history, agent);
      case ProviderType.google:
        return 'Google provider integration is not implemented yet.';
      case ProviderType.anthropic:
        return 'Anthropic provider integration is not implemented yet.';
    }
  }

  static List<Map<String, dynamic>> _composeMessages(
    List<ChatMessage> history,
    Agent agent,
    String userText,
  ) {
    final messages = <Map<String, dynamic>>[];
    if (agent.systemPrompt.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': agent.systemPrompt,
      });
    }

    for (final m in history) {
      messages.add({
        'role': _roleToString(m.role),
        'content': m.content,
      });
    }

    messages.add({
      'role': 'user',
      'content': userText,
    });

    return messages;
  }

  static Future<String> _callOpenAI(
    LLMProvider provider,
    String userText,
    List<ChatMessage> history,
    Agent agent,
  ) async {
    final messages = _composeMessages(history, agent, userText);
    final model =
        provider.models.isNotEmpty ? provider.models.first.id : 'gpt-4o-mini';

    final base = provider.baseUrl?.replaceAll(RegExp(r'/$'), '') ??
        'https://api.openai.com';
    // Removed `/v1/` segment to support proxies or custom gateways that expect root-level endpoints
    final url = Uri.parse('$base/chat/completions');

    final headers = <String, String>{
      'Authorization': 'Bearer ${provider.apiKey}',
      'Content-Type': 'application/json',
      ...provider.headers,
    };

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': agent.temperature ?? 0.7,
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        final content = choices != null &&
                choices.isNotEmpty &&
                choices.first['message'] != null
            ? choices.first['message']['content'] as String? ??
                'No content returned'
            : 'No choices returned';
        return content;
      }
      return 'OpenAI API error ${resp.statusCode}: ${resp.body}';
    } catch (e) {
      return 'Failed to call OpenAI: $e';
    }
  }

  static String _roleToString(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return 'user';
      case ChatRole.model:
        return 'assistant';
      case ChatRole.system:
        return 'system';
    }
  }
}