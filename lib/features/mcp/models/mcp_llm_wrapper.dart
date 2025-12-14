// Wrapper for MCP LLM integration
// This file provides a clean interface for integrating with mcp_llm package
// Currently using HTTP calls, but can be easily switched to mcp_llm when ready

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:ai_gateway/features/agents/dto/agent.dart';
import 'package:ai_gateway/features/home/models/chat_models.dart';

class McpLlmWrapper {
  /// Generate completion using MCP LLM
  /// This method will be updated to use actual mcp_llm package when integrated
  static Future<String> generateCompletion({
    required LLMProvider provider,
    required List<ChatMessage> messages,
    required Agent agent,
    String? model,
    double? temperature,
  }) async {
    // TODO: Replace with actual mcp_llm implementation
    // For now, fall back to HTTP calls
    return await _fallbackToHttp(provider, messages, agent, model, temperature);
  }

  /// Fallback method using HTTP calls
  /// This will be removed once mcp_llm is fully integrated
  static Future<String> _fallbackToHttp(
    LLMProvider provider,
    List<ChatMessage> messages,
    Agent agent,
    String? model,
    double? temperature,
  ) async {
    switch (provider.type) {
      case ProviderType.openai:
        return await _callOpenAI(provider, messages, agent, model, temperature);
      case ProviderType.anthropic:
        return await _callAnthropic(provider, messages, agent, model, temperature);
      case ProviderType.gemini:
        return await _callGemini(provider, messages, agent, model, temperature);
      case ProviderType.ollama:
        return await _callOllama(provider, messages, agent, model, temperature);
      }
  }

  /// OpenAI API call
  static Future<String> _callOpenAI(
    LLMProvider provider,
    List<ChatMessage> messages,
    Agent agent,
    String? model,
    double? temperature,
  ) async {
    final finalModel = model ?? (provider.models.isNotEmpty ? provider.models.first.id : 'gpt-4o-mini');
    final finalTemperature = temperature ?? agent.temperature ?? 0.7;

    final base = provider.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? 'https://api.openai.com';
    final url = Uri.parse('$base/chat/completions');

    final headers = <String, String>{
      'Authorization': 'Bearer ${provider.apiKey}',
      'Content-Type': 'application/json',
      ...provider.headers,
    };

    final formattedMessages = messages.map((m) => {
      'role': _roleToString(m.role),
      'content': m.content,
    }).toList();

    // Add system prompt if not already in messages
    if (agent.systemPrompt.isNotEmpty && !formattedMessages.any((m) => m['role'] == 'system')) {
      formattedMessages.insert(0, {
        'role': 'system',
        'content': agent.systemPrompt,
      });
    }

    final body = jsonEncode({
      'model': finalModel,
      'messages': formattedMessages,
      'temperature': finalTemperature,
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        final content = choices != null &&
                choices.isNotEmpty &&
                choices.first['message'] != null
            ? choices.first['message']['content'] as String? ?? 'No content returned'
            : 'No choices returned';
        return content;
      }
      return 'OpenAI API error ${resp.statusCode}: ${resp.body}';
    } catch (e) {
      return 'Failed to call OpenAI: $e';
    }
  }

  /// Anthropic API call
  static Future<String> _callAnthropic(
    LLMProvider provider,
    List<ChatMessage> messages,
    Agent agent,
    String? model,
    double? temperature,
  ) async {
    final finalModel = model ?? (provider.models.isNotEmpty ? provider.models.first.id : 'claude-3-5-sonnet-20241022');
    final finalTemperature = temperature ?? agent.temperature ?? 0.7;

    final base = provider.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? 'https://api.anthropic.com';
    final url = Uri.parse('$base/v1/messages');

    final headers = <String, String>{
      'x-api-key': provider.apiKey ?? '',
      'Content-Type': 'application/json',
      'anthropic-version': '2023-06-01',
      ...provider.headers,
    };

    final formattedMessages = messages
        .where((m) => m.role != ChatRole.system)
        .map((m) => {
              'role': _roleToAnthropic(m.role),
              'content': m.content,
            })
        .toList();

    final body = jsonEncode({
      'model': finalModel,
      'messages': formattedMessages,
      'system': agent.systemPrompt.isNotEmpty ? agent.systemPrompt : null,
      'temperature': finalTemperature,
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final content = data['content'] as List?;
        if (content != null && content.isNotEmpty && content.first['text'] != null) {
          return content.first['text'] as String;
        }
        return 'No content returned';
      }
      return 'Anthropic API error ${resp.statusCode}: ${resp.body}';
    } catch (e) {
      return 'Failed to call Anthropic: $e';
    }
  }

  /// Gemini API call
  static Future<String> _callGemini(
    LLMProvider provider,
    List<ChatMessage> messages,
    Agent agent,
    String? model,
    double? temperature,
  ) async {
    final finalModel = model ?? (provider.models.isNotEmpty ? provider.models.first.id : 'gemini-1.5-flash');
    final finalTemperature = temperature ?? agent.temperature ?? 0.7;

    final base = provider.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? 'https://generativelanguage.googleapis.com';
    final url = Uri.parse('$base/v1beta/models/$finalModel:generateContent?key=${provider.apiKey}');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...provider.headers,
    };

    final contents = <Map<String, dynamic>>[];
    
    // Add system instruction if available
    if (agent.systemPrompt.isNotEmpty) {
      contents.add({
        'role': 'user',
        'parts': [
          {'text': agent.systemPrompt},
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {'text': 'Understood. I will follow these instructions.'},
        ],
      });
    }

    // Add conversation history
    for (final m in messages) {
      if (m.role == ChatRole.user || m.role == ChatRole.model) {
        contents.add({
          'role': m.role == ChatRole.user ? 'user' : 'model',
          'parts': [
            {'text': m.content},
          ],
        });
      }
    }

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': finalTemperature,
      },
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty && parts.first['text'] != null) {
            return parts.first['text'] as String;
          }
        }
        return 'No content returned';
      }
      return 'Gemini API error ${resp.statusCode}: ${resp.body}';
    } catch (e) {
      return 'Failed to call Gemini: $e';
    }
  }

  /// Ollama API call
  static Future<String> _callOllama(
    LLMProvider provider,
    List<ChatMessage> messages,
    Agent agent,
    String? model,
    double? temperature,
  ) async {
    final finalModel = model ?? (provider.models.isNotEmpty ? provider.models.first.id : 'llama2');
    final finalTemperature = temperature ?? agent.temperature ?? 0.7;

    final base = provider.baseUrl?.replaceAll(RegExp(r'/$'), '') ?? 'http://localhost:11434';
    final url = Uri.parse('$base/api/chat');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      ...provider.headers,
    };

    final formattedMessages = messages.map((m) => {
      'role': _roleToString(m.role),
      'content': m.content,
    }).toList();

    // Add system prompt if not already in messages
    if (agent.systemPrompt.isNotEmpty && !formattedMessages.any((m) => m['role'] == 'system')) {
      formattedMessages.insert(0, {
        'role': 'system',
        'content': agent.systemPrompt,
      });
    }

    final body = jsonEncode({
      'model': finalModel,
      'messages': formattedMessages,
      'stream': false,
      'options': {
        'temperature': finalTemperature,
      },
    });

    try {
      final resp = await http.post(url, headers: headers, body: body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final message = data['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        return content ?? 'No content returned';
      }
      return 'Ollama API error ${resp.statusCode}: ${resp.body}';
    } catch (e) {
      return 'Failed to call Ollama: $e';
    }
  }

  /// Convert ChatRole to string for API
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

  /// Convert ChatRole to Anthropic format
  static String _roleToAnthropic(ChatRole role) {
    switch (role) {
      case ChatRole.user:
        return 'user';
      case ChatRole.model:
        return 'assistant';
      case ChatRole.system:
        return 'user'; // Anthropic doesn't have system role, handled separately
    }
  }
}