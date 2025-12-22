import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../base.dart';
import '../ai_utils.dart';
import '../../../core/models/ai/ai_model.dart';

class OpenAI extends AIBaseApi {
  final String responsesPath;
  final String chatPath;
  final String modelsPath;
  final String embeddingsPath;
  final String imagesGenerationsPath;
  final String imagesEditsPath;
  final String videosPath;
  final String audioSpeechPath;

  OpenAI({
    super.apiKey = '',
    required super.baseUrl,
    this.responsesPath = '/responses',
    this.chatPath = '/chat/completions',
    this.modelsPath = '/models',
    this.embeddingsPath = '/embeddings',
    this.imagesGenerationsPath = '/images/generations',
    this.imagesEditsPath = '/images/edits',
    this.videosPath = '/videos',
    this.audioSpeechPath = '/audio/speech',
    super.headers = const {},
  });

  Map<String, dynamic> _buildPayload(AIRequest request, {bool stream = false}) {
    final payload = <String, dynamic>{
      'model': request.model,
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
    String inferMode() {
      final m = request.extra['mode'];
      if (m is String && m.isNotEmpty) return m;
      if (request.images.isNotEmpty && request.messages.isEmpty) return 'image';
      if (request.audios.isNotEmpty && request.messages.isEmpty) {
        return 'audio_speech';
      }
      return 'chat';
    }

    final mode = (request.extra['mode'] as String?) ?? inferMode();

    if (mode == 'responses') {
      final input = <Map<String, dynamic>>[];

      for (final msg in request.messages) {
        for (final c in msg.content) {
          if (c.type == AIContentType.text && (c.text ?? '').isNotEmpty) {
            input.add({'type': 'input_text', 'text': c.text});
          } else if (c.type == AIContentType.image) {
            final url = (c.uri != null && c.uri!.isNotEmpty)
                ? c.uri
                : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                      ? encodeDataUrl(
                          mimeType: c.mimeType!,
                          base64Data: c.dataBase64!,
                        )
                      : null);
            if (url != null) {
              input.add({
                'type': 'input_image',
                'image_url': {'url': url},
              });
            }
          }
        }
      }

      // also include request-level images
      for (final c in request.images) {
        if (c.type == AIContentType.image) {
          final url = (c.uri != null && c.uri!.isNotEmpty)
              ? c.uri
              : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                    ? encodeDataUrl(
                        mimeType: c.mimeType!,
                        base64Data: c.dataBase64!,
                      )
                    : null);
          if (url != null) {
            input.add({
              'type': 'input_image',
              'image_url': {'url': url},
            });
          }
        }
      }

      final body = <String, dynamic>{
        'model': request.model,
        'input': input,
        if (request.temperature != null) 'temperature': request.temperature,
        if (request.maxTokens != null) 'max_output_tokens': request.maxTokens,
        if (request.tools.isNotEmpty) 'tools': toOpenAITools(request.tools),
        if (request.toolChoice != null)
          'tool_choice': toOpenAIToolChoice(request.toolChoice!),
        ...request.extra,
      };

      final res = await http.post(
        uri(responsesPath),
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        String txt = '';
        if (j['output_text'] is String) {
          txt = j['output_text'] as String;
        } else if (j['response'] is String) {
          txt = j['response'] as String;
        } else if (j['output'] is String) {
          txt = j['output'] as String;
        } else if (j['choices'] is List) {
          return parseOpenAIResponse(j);
        } else {
          txt = j.toString();
        }
        return AIResponse(text: txt, raw: j);
      }
      throw Exception('OpenAI responses error ${res.statusCode}: ${res.body}');
    }

    if (mode == 'image') {
      final prompt =
          (request.extra['prompt'] as String?) ??
          request.messages
              .map((m) => ensureTextFromContent(m.content))
              .where((s) => s.trim().isNotEmpty)
              .join('\n');

      final body = <String, dynamic>{
        'prompt': prompt,
        'model': request.model,
        if (request.extra['n'] != null) 'n': request.extra['n'],
        if (request.extra['size'] != null) 'size': request.extra['size'],
        if (request.extra['quality'] != null)
          'quality': request.extra['quality'],
        if (request.extra['response_format'] != null)
          'response_format': request.extra['response_format'],
        ...request.extra,
      };

      final res = await http.post(
        uri(imagesGenerationsPath),
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
      throw Exception('OpenAI images error ${res.statusCode}: ${res.body}');
    }

    if (mode == 'audio_speech') {
      final inputText =
          (request.extra['input'] as String?) ??
          request.messages
              .map((m) => ensureTextFromContent(m.content))
              .where((s) => s.trim().isNotEmpty)
              .join('\n');
      final voice = (request.extra['voice'] as String?) ?? 'alloy';
      final responseFormat =
          (request.extra['response_format'] as String?) ?? 'mp3';
      final accept = responseFormat == 'wav' ? 'audio/wav' : 'audio/mpeg';

      final body = <String, dynamic>{
        'model': request.model,
        'input': inputText,
        'voice': voice,
        'response_format': responseFormat,
        ...request.extra,
      };

      final res = await http.post(
        uri(audioSpeechPath),
        headers: getHeaders(overrides: {'Accept': accept}),
        body: jsonEncode(body),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bytes = res.bodyBytes;
        final b64 = base64Encode(bytes);
        final content = AIContent(
          type: AIContentType.audio,
          dataBase64: b64,
          mimeType: accept,
        );
        return AIResponse(
          text: '',
          contents: [content],
          raw: {'content_type': accept},
        );
      }
      throw Exception(
        'OpenAI audio speech error ${res.statusCode}: ${res.body}',
      );
    }

    if (mode == 'video') {
      final prompt =
          (request.extra['prompt'] as String?) ??
          request.messages
              .map((m) => ensureTextFromContent(m.content))
              .where((s) => s.trim().isNotEmpty)
              .join('\n');

      final body = <String, dynamic>{
        'model': request.model,
        'prompt': prompt,
        ...request.extra,
      };

      final res = await http.post(
        uri(videosPath),
        headers: getHeaders(),
        body: jsonEncode(body),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        final contents = <AIContent>[];
        final data = j['data'];
        if (data is List) {
          for (final it in data) {
            final m = (it as Map).cast<String, dynamic>();
            if (m['b64_json'] is String) {
              contents.add(
                AIContent(
                  type: AIContentType.video,
                  dataBase64: m['b64_json'] as String,
                  mimeType: 'video/mp4',
                ),
              );
            } else if (m['url'] is String) {
              contents.add(
                AIContent(type: AIContentType.video, uri: m['url'] as String),
              );
            }
          }
        }
        return AIResponse(text: '', contents: contents, raw: j);
      }
      throw Exception('OpenAI videos error ${res.statusCode}: ${res.body}');
    }

    // default chat
    final payload = _buildPayload(request, stream: false);
    final res = await http.post(
      uri(chatPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return parseOpenAIResponse(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('OpenAI error ${res.statusCode}: ${res.body}');
  }

  @override
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final mode = (request.extra['mode'] as String?) ?? 'chat';
    final String path;
    final Map<String, dynamic> payload;

    if (mode == 'responses') {
      path = responsesPath;
      final input = <Map<String, dynamic>>[];
      for (final msg in request.messages) {
        for (final c in msg.content) {
          if (c.type == AIContentType.text && (c.text ?? '').isNotEmpty) {
            input.add({'type': 'input_text', 'text': c.text});
          } else if (c.type == AIContentType.image) {
            final url = (c.uri != null && c.uri!.isNotEmpty)
                ? c.uri
                : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                      ? encodeDataUrl(
                          mimeType: c.mimeType!,
                          base64Data: c.dataBase64!,
                        )
                      : null);
            if (url != null) {
              input.add({
                'type': 'input_image',
                'image_url': {'url': url},
              });
            }
          }
        }
      }
      for (final c in request.images) {
        if (c.type == AIContentType.image) {
          final url = (c.uri != null && c.uri!.isNotEmpty)
              ? c.uri
              : ((c.dataBase64 != null && (c.mimeType ?? '').isNotEmpty)
                    ? encodeDataUrl(
                        mimeType: c.mimeType!,
                        base64Data: c.dataBase64!,
                      )
                    : null);
          if (url != null) {
            input.add({
              'type': 'input_image',
              'image_url': {'url': url},
            });
          }
        }
      }
      payload = {
        'model': request.model,
        'input': input,
        'stream': true,
        ...request.extra,
      };
    } else {
      path = chatPath;
      payload = _buildPayload(request, stream: true);
    }

    final rq = http.Request('POST', uri(path))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('OpenAI stream error ${rs.statusCode}: $body');
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

          // Handle top-level delta (for responses mode)
          if (j.containsKey('delta') && j['delta'] is String) {
            final d = j['delta'] as String;
            if (d.isNotEmpty) {
              buffer.write(d);
              yield AIResponse(text: d);
              continue;
            }
          }

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
    final res = await http.get(uri(modelsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (j['data'] as List? ?? const []);
      return data
          .map((e) => AIModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    // Fallback nếu API list models lỗi hoặc không được hỗ trợ (một số provider tương thích OpenAI nhưng chặn endpoint này)
    return [];
  }

  @override
  Future<dynamic> embed({
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  }) async {
    final body = {'model': model, 'input': input, ...options};
    final res = await http.post(
      uri(embeddingsPath),
      headers: getHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('OpenAI embed error ${res.statusCode}: ${res.body}');
  }
}
