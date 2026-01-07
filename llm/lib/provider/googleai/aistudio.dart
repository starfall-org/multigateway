import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:llm/models/llm_api/googleai/embeddings.dart';
import 'package:llm/models/llm_api/googleai/generate_content.dart';
import 'package:llm/models/llm_api/googleai/models.dart';
import 'package:llm/provider/base.dart';

class GoogleAiStudio extends LlmProviderBase {
  final String generateContentPath;
  final String streamGenerateContentPath;
  final String embeddingsPath;
  final String modelsPath;

  GoogleAiStudio({
    super.apiKey = '',
    required super.baseUrl,
    this.generateContentPath = '/v1beta/models/{model}:generateContent',
    this.streamGenerateContentPath =
        '/v1beta/models/{model}:streamGenerateContent',
    this.embeddingsPath = '/v1beta/models/{model}:embedContent',
    this.modelsPath = '/v1beta/models',
    super.headers = const {},
  });

  @override
  Map<String, String> getHeaders({Map<String, String> overrides = const {}}) {
    return {'Content-Type': 'application/json', ...headers, ...overrides};
  }

  Uri _buildUri(
    String pathTemplate,
    String model, {
    Map<String, String>? queryParams,
  }) {
    final path = pathTemplate.replaceAll('{model}', model);
    final baseUri = uri(path);

    final params = <String, String>{
      if (apiKey.isNotEmpty) 'key': apiKey,
      ...?queryParams,
    };

    return baseUri.replace(queryParameters: params);
  }

  Future<GeminiGenerateContentResponse> generateContent({
    required String model,
    required GeminiGenerateContentRequest request,
  }) async {
    final payload = request.toJson();
    final res = await http.post(
      _buildUri(generateContentPath, model),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return GeminiGenerateContentResponse.fromJson(j);
    }
    throw Exception(
      'GoogleAI generateContent error ${res.statusCode}: ${res.body}',
    );
  }

  Stream<GeminiGenerateContentResponse> generateContentStream({
    required String model,
    required GeminiGenerateContentRequest request,
  }) async* {
    final payload = request.toJson();
    final rq =
        http.Request(
            'POST',
            _buildUri(
              streamGenerateContentPath,
              model,
              queryParams: {'alt': 'sse'},
            ),
          )
          ..headers.addAll(getHeaders())
          ..body = jsonEncode(payload);
    final rs = await rq.send();

    if (rs.statusCode < 200 || rs.statusCode >= 300) {
      final body = await rs.stream.bytesToString();
      throw Exception(
        'GoogleAI generateContentStream error ${rs.statusCode}: $body',
      );
    }

    await for (final chunk in rs.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data.trim().isNotEmpty) {
            try {
              final j = jsonDecode(data) as Map<String, dynamic>;
              final response = GeminiGenerateContentResponse.fromJson(j);
              yield response;
            } catch (_) {
              // Skip invalid JSON chunks
            }
          }
        }
      }
    }
  }

  Future<GeminiEmbeddingsResponse> embedContent({
    required String model,
    required GeminiEmbeddingsRequest request,
  }) async {
    final payload = request.toJson();
    final res = await http.post(
      _buildUri(embeddingsPath, model),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return GeminiEmbeddingsResponse.fromJson(j);
    }
    throw Exception(
      'GoogleAI embedContent error ${res.statusCode}: ${res.body}',
    );
  }

  Future<GeminiBatchEmbeddingsResponse> batchEmbedContents({
    required String model,
    required GeminiBatchEmbeddingsRequest request,
  }) async {
    final payload = request.toJson();
    final res = await http.post(
      _buildUri('/v1beta/models/$model:batchEmbedContents', model),
      headers: getHeaders(),
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return GeminiBatchEmbeddingsResponse.fromJson(j);
    }
    throw Exception(
      'GoogleAI batchEmbedContents error ${res.statusCode}: ${res.body}',
    );
  }

  Future<GeminiModelsResponse> listModels({
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      if (apiKey.isNotEmpty) 'key': apiKey,
      if (pageSize != null) 'pageSize': pageSize.toString(),
      if (pageToken != null) 'pageToken': pageToken,
    };

    final res = await http.get(
      uri(modelsPath).replace(queryParameters: queryParams),
      headers: getHeaders(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return GeminiModelsResponse.fromJson(j);
    }
    throw Exception('GoogleAI listModels error ${res.statusCode}: ${res.body}');
  }

  Future<GeminiModel> getModel({required String model}) async {
    final queryParams = <String, String>{if (apiKey.isNotEmpty) 'key': apiKey};

    final res = await http.get(
      uri('/v1beta/models/$model').replace(queryParameters: queryParams),
      headers: getHeaders(),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      return GeminiModel.fromJson(j);
    }
    throw Exception('GoogleAI getModel error ${res.statusCode}: ${res.body}');
  }
}
