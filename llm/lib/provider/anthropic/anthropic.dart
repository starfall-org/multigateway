import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/llm_api/anthropic/messages.dart';
import '../../models/llm_api/anthropic/models.dart';
import '../base.dart';

class AnthropicProvider extends LlmProviderBase {
  final String messagesPath;
  final String modelsPath;
  final String anthropicVersion;

  AnthropicProvider({
    super.apiKey = '',
    required super.baseUrl,
    this.messagesPath = '/messages',
    this.modelsPath = '/models',
    this.anthropicVersion = '2023-06-01',
    super.headers = const {},
  });

  @override
  Map<String, String> getHeaders({Map<String, String> overrides = const {}}) {
    return {
      'Content-Type': 'application/json',
      'anthropic-version': anthropicVersion,
      if (apiKey.isNotEmpty) 'x-api-key': apiKey,
      ...headers,
      ...overrides,
    };
  }

  Future<AnthropicMessagesResponse> messages(
    AnthropicMessagesRequest request,
  ) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(messagesPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return AnthropicMessagesResponse.fromJson(j);
    }
    throw Exception(
      'AnthropicProvider messages error ${res.statusCode}: ${res.body}',
    );
  }

  Stream<AnthropicMessagesResponse> messagesStream(
    AnthropicMessagesRequest request,
  ) async* {
    final payload = request.toJson();
    final rq = http.Request('POST', uri(messagesPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception(
        'AnthropicProvider messages stream error ${rs.statusCode}: $body',
      );
    }

    await for (final chunk in rs.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('data:')) continue;
        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') {
          return;
        }
        try {
          final j = jsonDecode(data) as Map<String, dynamic>;
          final type = j['type'] as String? ?? j['event'] as String? ?? '';
          if (type == 'content_block_delta') {
            final delta =
                (j['delta'] as Map?)?.cast<String, dynamic>() ?? const {};
            if ((delta['type'] as String? ?? '') == 'text_delta') {
              final t = delta['text'] as String? ?? '';
              if (t.isNotEmpty) {
                // Create a partial response for streaming
                final response = AnthropicMessagesResponse(
                  id: 'stream',
                  type: 'message',
                  role: 'assistant',
                  content: [AnthropicContent(type: 'text', text: t)],
                  model: request.model,
                  stopReason: null,
                  stopSequence: null,
                  usage: AnthropicUsage(inputTokens: 0, outputTokens: 0),
                );
                yield response;
              }
            }
          } else if (type == 'message_delta') {
            final delta =
                (j['delta'] as Map?)?.cast<String, dynamic>() ?? const {};
            final stop = delta['stop_reason'] as String?;
            if (stop != null) {
              final response = AnthropicMessagesResponse(
                id: 'stream',
                type: 'message',
                role: 'assistant',
                content: [],
                model: request.model,
                stopReason: stop,
                stopSequence: null,
                usage: AnthropicUsage(inputTokens: 0, outputTokens: 0),
              );
              yield response;
            }
          }
        } catch (_) {
          // ignore malformed chunks
        }
      }
    }
  }

  Future<AnthropicModels> listModels() async {
    final res = await http.get(uri(modelsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return AnthropicModels.fromJson(j);
    }
    throw Exception(
      'AnthropicProvider list models error ${res.statusCode}: ${res.body}',
    );
  }
}
