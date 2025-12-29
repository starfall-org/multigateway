import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base.dart';
import '../../utils.dart';

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

  Map<String, dynamic> _buildPayload(AIRequest request, {bool stream = false}) {
    return {
      'model': request.model,
      'messages': toOllamaMessages(
        request.messages,
        extraImages: request.images,
      ),
      if (request.temperature != null) 'temperature': request.temperature,
      if (request.maxTokens != null) 'num_predict': request.maxTokens,
      if (stream) 'stream': true,
      ...request.extra,
    };
  }

  @override
  Future<AIResponse> generate(AIRequest request) async {
    final payload = _buildPayload(request, stream: false);
    final res = await http.post(
      uri(chatPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return parseOllamaResponse(j);
    }
    throw Exception('Ollama error ${res.statusCode}: ${res.body}');
  }

  @override
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final payload = _buildPayload(request, stream: true);
    final rq = http.Request('POST', uri(chatPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();
    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('Ollama stream error ${rs.statusCode}: $body');
    }

    await for (final chunk in rs.stream.transform(utf8.decoder)) {
      for (final line in const LineSplitter().convert(chunk)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final j = jsonDecode(trimmed) as Map<String, dynamic>;
          final done = j['done'] as bool? ?? false;
          final msg =
              (j['message'] as Map?)?.cast<String, dynamic>() ?? const {};
          final delta = (msg['content'] as String?) ?? '';
          if (delta.isNotEmpty) {
            yield AIResponse(text: delta);
          }
          if (done) {
            return;
          }
        } catch (_) {}
      }
    }
  }

  @override
  Future<List<AIModel>> listModels() async {
    final res = await http.get(uri(tagsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      final data = (j['models'] as List? ?? const []);
      return data
          .map((e) => AIModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw Exception('Ollama list models error ${res.statusCode}: ${res.body}');
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
    throw Exception('Ollama embed error ${res.statusCode}: ${res.body}');
  }
}
