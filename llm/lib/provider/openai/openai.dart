import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/llm_api/openai/audio_speech.dart';
import '../../models/llm_api/openai/chat_completions.dart';
import '../../models/llm_api/openai/embeddings.dart';
import '../../models/llm_api/openai/image_generations.dart';
import '../../models/llm_api/openai/models.dart';
import '../../models/llm_api/openai/videos.dart';
import '../base.dart';
import '../../models/llm_api/openai/responses.dart';

class OpenAiProvider extends LlmProviderBase {
  final String responsesPath;
  final String chatPath;
  final String modelsPath;
  final String embeddingsPath;
  final String imagesGenerationsPath;
  final String imagesEditsPath;
  final String videosPath;
  final String audioSpeechPath;

  OpenAiProvider({
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

  Future<OpenAiResponses> responses(OpenAiResponsesRequest request) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(responsesPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiResponses.fromJson(j);
    }
    throw Exception(
      'OpenAiProvider responses error ${res.statusCode}: ${res.body}',
    );
  }

  Future<OpenAiChatCompletions> chatCompletions(
    OpenAiChatCompletionsRequest request,
  ) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(chatPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiChatCompletions.fromJson(j);
    }
    throw Exception('OpenAiProvider error ${res.statusCode}: ${res.body}');
  }

  Stream<OpenAiResponses> responsesStream(
    OpenAiResponsesRequest request,
  ) async* {
    final payload = request.toJson();
    final rq = http.Request('POST', uri(responsesPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception(
        'OpenAiProvider responses stream error ${rs.statusCode}: $body',
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
          // Parse thành OpenAiResponses
          final response = OpenAiResponses.fromJson(j);
          yield response;
        } catch (_) {
          // ignore malformed chunks
        }
      }
    }
  }

  Stream<OpenAiChatCompletions> chatCompletionsStream(
    OpenAiChatCompletionsRequest request,
  ) async* {
    final payload = request.toJson();
    final rq = http.Request('POST', uri(chatPath))
      ..headers.addAll(getHeaders())
      ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception('OpenAiProvider stream error ${rs.statusCode}: $body');
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
          final response = OpenAiChatCompletions.fromJson(j);
          yield response;
        } catch (_) {
          // ignore malformed chunks
        }
      }
    }
  }

  Future<OpenAiImagesGenerations> imagesGenerations(
    OpenAiImagesGenerationsRequest request,
  ) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(imagesGenerationsPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiImagesGenerations.fromJson(j);
    }
    throw Exception(
      'OpenAiProvider images error ${res.statusCode}: ${res.body}',
    );
  }

  Future<OpenAiAudioSpeech> audioSpeech(
    OpenAiAudioSpeechRequest request,
  ) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(audioSpeechPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final bytes = res.bodyBytes;
      final b64 = base64Encode(bytes);
      return OpenAiAudioSpeech(audioContent: b64);
    }
    throw Exception(
      'OpenAiProvider audio speech error ${res.statusCode}: ${res.body}',
    );
  }

  Future<OpenAiVideos> videos(OpenAiVideosRequest request) async {
    final payload = request.toJson();
    final res = await http.post(
      uri(videosPath),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiVideos.fromJson(j);
    }
    throw Exception(
      'OpenAiProvider videos error ${res.statusCode}: ${res.body}',
    );
  }

  Future<OpenAiModels> listModels() async {
    final res = await http.get(uri(modelsPath), headers: getHeaders());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiModels.fromJson(j);
    }
    throw Exception(
      'OpenAiProvider list models error ${res.statusCode}: ${res.body}',
    );
  }

  Future<OpenAiEmbeddings> embeddings({
    required OpenAiEmbeddingsRequest request,
  }) async {
    final body = request.toJson();
    final res = await http.post(
      uri(embeddingsPath),
      headers: getHeaders(),
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return OpenAiEmbeddings.fromJson(j);
    }
    throw Exception(
      'OpenAiProvider embed error ${res.statusCode}: ${res.body}',
    );
  }
}
