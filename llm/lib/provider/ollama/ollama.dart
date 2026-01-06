import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/llm_api/ollama/chat.dart';
import '../../models/llm_api/ollama/embed.dart';
import '../../models/llm_api/ollama/tags.dart';
import '../base.dart';

class Ollama extends AIBaseApi {
  final String chatPath;
  final String tagsPath;
  final String embeddingsPath;

  Ollama({
    super.apiKey = '',
    required super.baseUrl,
    this.chatPath = '/api/chat',
    this.tagsPath = '/api/tags',
    this.embeddingsPath = '/api/embeddings',
    super.headers = const {},
  });

  Future<OllamaChatResponse> chat(OllamaChatRequest request) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(chatPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OllamaChatResponse.fromJson(j);
    }
    throw Exception('Ollama chat error ${res.statusCode}: ${res.body}');
  }

  Stream<OllamaChatStreamResponse> chatStream(OllamaChatRequest request) async* {
    final payload = request.toJson();
    final rq = http.Request('POST', uri(chatPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();
    
    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('Ollama chat stream error ${rs.statusCode}: $body');
    }

    await for (final chunk in rs.stream.transform(utf8.decoder)) {
      for (final line in const LineSplitter().convert(chunk)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final j = jsonDecode(trimmed) as Map<String, dynamic>;
          final response = OllamaChatStreamResponse.fromJson(j);
          yield response;
          if (response.done == true) {
            return;
          }
        } catch (_) {
          // ignore malformed chunks
        }
      }
    }
  }

  Future<OllamaTagsResponse> listModels() async {
    final res = await http.get(uri(tagsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OllamaTagsResponse.fromJson(j);
    }
    throw Exception('Ollama list models error ${res.statusCode}: ${res.body}');
  }

  Future<OllamaEmbedResponse> embeddings(OllamaEmbedRequest request) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(embeddingsPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OllamaEmbedResponse.fromJson(j);
    }
    throw Exception('Ollama embeddings error ${res.statusCode}: ${res.body}');
  }
}