import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'base.dart';
import 'ai_utils.dart';
import '../../models/ai/ai_model.dart';

class Anthropic extends AIBaseApi {
  final String messagesPath;
  final String modelsPath;
  final String anthropicVersion;

  Anthropic({
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

  Map<String, dynamic> _buildPayload(AIRequest request, {bool stream = false}) {
    final split = splitSystemAndMessages(request.messages);
    final system = split.$1;
    final msgs = split.$2;

    final payload = <String, dynamic>{
      'model': request.model,
      'messages': toAnthropicMessages(msgs, extraImages: request.images),
      'max_tokens': request.maxTokens ?? 1024,
      if (system != null) 'system': system,
      if (request.temperature != null) 'temperature': request.temperature,
      if (request.tools.isNotEmpty) 'tools': toAnthropicTools(request.tools),
      if (request.toolChoice != null)
        'tool_choice': toAnthropicToolChoice(request.toolChoice!),
      if (stream) 'stream': true,
      ...request.extra,
    };
    return payload;
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    final payload = _buildPayload(request, stream: false);
    final res = await http.post(
      uri(messagesPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseAnthropicResponse(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Anthropic error ${res.statusCode}: ${res.body}');
  }

  @override
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final payload = _buildPayload(request, stream: true);
    final rq = http.Request('POST', uri(messagesPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('Anthropic stream error ${rs.statusCode}: $body');
    }

    final buffer = StringBuffer();
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
                buffer.write(t);
                yield AIResponse(text: t);
              }
            }
          } else if (type == 'message_delta') {
            final delta =
                (j['delta'] as Map?)?.cast<String, dynamic>() ?? const {};
            final stop = delta['stop_reason'] as String?;
            if (stop != null) {
              yield AIResponse(text: '', finishReason: stop);
            }
          }
        } catch (_) {}
      }
    }
  }

  @override
  Future<List<AIModel>> listModels() async {
    final res = await http.get(uri(modelsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (j['data'] as List? ?? const []);
      return data
          .map((e) => AIModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw Exception(
      'Anthropic list models error ${res.statusCode}: ${res.body}',
    );
  }

  @override
  Future<dynamic> embed({
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  }) {
    throw UnsupportedError(
      'Anthropic does not support embeddings in this client.',
    );
  }
}
