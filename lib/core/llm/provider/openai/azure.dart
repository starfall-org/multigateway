import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../base.dart';
import '../../utils.dart';

/// Azure OpenAI Service
/// Tương thích với OpenAI API nhưng sử dụng Azure endpoints
class AzureOpenAI extends AIBaseApi {
  final String deploymentId;
  final String apiVersion;
  final String chatPath;
  final String embeddingsPath;
  final String imagesGenerationsPath;

  AzureOpenAI({
    super.apiKey = '',
    required super.baseUrl,
    required this.deploymentId,
    this.apiVersion = '2024-02-15-preview',
    this.chatPath = '/openai/deployments/{deployment-id}/chat/completions',
    this.embeddingsPath = '/openai/deployments/{deployment-id}/embeddings',
    this.imagesGenerationsPath =
        '/openai/deployments/{deployment-id}/images/generations',
    super.headers = const {},
  });

  @override
  Map<String, String> getHeaders({Map<String, String> overrides = const {}}) {
    final result = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'api-key': apiKey,
      ...headers,
      ...overrides,
    };
    return result;
  }

  Uri _buildUri(String path) {
    final normalizedPath = path.replaceAll('{deployment-id}', deploymentId);
    final fullPath = normalizedPath.startsWith('/')
        ? normalizedPath
        : '/$normalizedPath';
    return Uri.parse('$baseUrl$fullPath?api-version=$apiVersion');
  }

  Map<String, dynamic> _buildPayload(AIRequest request, {bool stream = false}) {
    final payload = <String, dynamic>{
      'messages': toOpenAIMessages(
        request.messages,
        extraImages: request.images,
      ),
      if (request.tools.isNotEmpty) 'tools': toOpenAITools(request.tools),
      if (request.toolChoice != null)
        'tool_choice': toOpenAIToolChoice(request.toolChoice!),
      if (request.temperature != null) 'temperature': request.temperature,
      if (request.maxTokens != null) 'max_tokens': request.maxTokens,
      if (stream) 'stream': true,
      ...request.extra,
    };
    return payload;
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    final mode = (request.extra['mode'] as String?) ?? 'chat';

    if (mode == 'image') {
      final prompt =
          (request.extra['prompt'] as String?) ??
          request.messages
              .map((m) => ensureTextFromContent(m.content))
              .where((s) => s.trim().isNotEmpty)
              .join('\n');

      final body = <String, dynamic>{
        'prompt': prompt,
        if (request.extra['n'] != null) 'n': request.extra['n'],
        if (request.extra['size'] != null) 'size': request.extra['size'],
        if (request.extra['quality'] != null)
          'quality': request.extra['quality'],
        if (request.extra['response_format'] != null)
          'response_format': request.extra['response_format'],
        ...request.extra,
      };

      final res = await http.post(
        _buildUri(imagesGenerationsPath),
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final data = (j['data'] as List? ?? const []);
        final contents = <AIContent>[];
        for (final it in data) {
          final m = (it as Map).cast<String, dynamic>();
          if (m['b64_json'] is String) {
            contents.add(
              AIContent(
                type: AIContentType.image,
                dataBase64: m['b64_json'] as String,
                mimeType: 'image/png',
              ),
            );
          } else if (m['url'] is String) {
            contents.add(
              AIContent(type: AIContentType.image, uri: m['url'] as String),
            );
          }
        }
        return AIResponse(text: '', contents: contents, raw: j);
      }
      throw Exception(
        'Azure OpenAI images error ${res.statusCode}: ${res.body}',
      );
    }

    // default chat
    final payload = _buildPayload(request, stream: false);
    final res = await http.post(
      _buildUri(chatPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseOpenAIResponse(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Azure OpenAI error ${res.statusCode}: ${res.body}');
  }

  @override
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final payload = _buildPayload(request, stream: true);

    final rq = http.Request('POST', _buildUri(chatPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('Azure OpenAI stream error ${rs.statusCode}: $body');
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

          final choices = (j['choices'] as List? ?? const []);
          if (choices.isEmpty) continue;
          final delta =
              ((choices.first as Map)['delta'] as Map?)
                  ?.cast<String, dynamic>() ??
              const {};
          if (delta.containsKey('content')) {
            final c = delta['content'];
            if (c is String) {
              buffer.write(c);
              yield AIResponse(text: c);
            } else if (c is List) {
              for (final p in c) {
                final mp = (p as Map).cast<String, dynamic>();
                if (mp['type'] == 'text') {
                  final t = (mp['text'] as String?) ?? '';
                  if (t.isNotEmpty) {
                    buffer.write(t);
                    yield AIResponse(text: t);
                  }
                }
              }
            }
          }
        } catch (_) {
          // ignore malformed chunks
        }
      }
    }
  }

  @override
  Future<List<AIModel>> listModels() async {
    // Azure OpenAI không có endpoint list models như OpenAI
    // Trả về danh sách models trống
    return [];
  }

  @override
  Future<dynamic> embed({
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  }) async {
    final body = {'input': input, ...options};
    final res = await http.post(
      _buildUri(embeddingsPath),
      headers: getHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('Azure OpenAI embed error ${res.statusCode}: ${res.body}');
  }
}
