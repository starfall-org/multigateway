import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ai_features/provider.dart';
import '../base.dart';

class GoogleAIStudio {
  final String _defaultModel;
  final Provider? _provider;

  GoogleAIStudio({String defaultModel = 'gemini-1.5-flash', Provider? provider})
    : _defaultModel = defaultModel,
      _provider = provider;

  String get _apiKey => _provider?.apiKey ?? '';
  String get _baseUrl =>
      _provider?.baseUrl ?? 'https://generativelanguage.googleapis.com';

  /// Generate content với AIRequest (sử dụng DTO chung)
  Future<AIResponse> generate(AIRequest request) async {
    final model = request.model.isEmpty ? _defaultModel : request.model;
    final url = Uri.parse(
      '$_baseUrl/v1beta/models/$model:generateContent?key=$_apiKey',
    );

    final body = _buildRequestBody(request);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResponse(json);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Generate content với streaming (sử dụng DTO chung)
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final model = request.model.isEmpty ? _defaultModel : request.model;
    final url = Uri.parse(
      '$_baseUrl/v1beta/models/$model:streamGenerateContent?alt=sse&key=$_apiKey',
    );

    final body = _buildRequestBody(request);

    final client = http.Client();
    try {
      final streamRequest = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);

      final streamResponse = await client.send(streamRequest);

      if (streamResponse.statusCode >= 200 && streamResponse.statusCode < 300) {
        await for (final chunk in streamResponse.stream.transform(
          utf8.decoder,
        )) {
          final lines = chunk.split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6);
              if (data.trim().isNotEmpty) {
                try {
                  final json = jsonDecode(data) as Map<String, dynamic>;
                  final response = _parseResponse(json);
                  if (response.text.isNotEmpty) {
                    yield response;
                  }
                } catch (e) {
                  // Skip invalid JSON chunks
                }
              }
            }
          }
        }
      } else {
        throw Exception('API Error: ${streamResponse.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  /// Build request body từ AIRequest
  Map<String, dynamic> _buildRequestBody(AIRequest request) {
    final contents = <Map<String, dynamic>>[];

    for (final msg in request.messages) {
      final parts = <Map<String, dynamic>>[];

      for (final content in msg.content) {
        switch (content.type) {
          case AIContentType.text:
            if (content.text?.isNotEmpty ?? false) {
              parts.add({'text': content.text});
            }
            break;
          case AIContentType.image:
            if (content.dataBase64 != null) {
              parts.add({
                'inlineData': {
                  'mimeType': content.mimeType ?? 'image/jpeg',
                  'data': content.dataBase64,
                },
              });
            }
            break;
          default:
            break;
        }
      }

      // Thêm extra images nếu có
      if (msg.role == 'user') {
        for (final img in request.images) {
          if (img.dataBase64 != null) {
            parts.add({
              'inlineData': {
                'mimeType': img.mimeType ?? 'image/jpeg',
                'data': img.dataBase64,
              },
            });
          }
        }
      }

      if (parts.isNotEmpty) {
        contents.add({
          'role': msg.role == 'user' ? 'user' : 'model',
          'parts': parts,
        });
      }
    }

    final body = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        if (request.temperature != null) 'temperature': request.temperature,
        if (request.maxTokens != null) 'maxOutputTokens': request.maxTokens,
      },
    };

    // Thêm tools nếu có
    if (request.tools.isNotEmpty) {
      final toolsList = <Map<String, dynamic>>[];

      // Filter special tools vs function declarations
      final functionDeclarations = <Map<String, dynamic>>[];
      bool hasGoogleSearch = false;
      bool hasCodeExecution = false;

      for (final tool in request.tools) {
        if (tool.name == '__google_search__') {
          hasGoogleSearch = true;
        } else if (tool.name == '__code_execution__') {
          hasCodeExecution = true;
        } else if (tool.name == '__url_context__') {
          // Dynamic Retrieval or Search can handle URL context
          hasGoogleSearch = true;
        } else {
          functionDeclarations.add({
            'name': tool.name,
            if (tool.description != null) 'description': tool.description,
            'parameters': tool.parameters,
          });
        }
      }

      final isGemini2 = request.model.contains('2.0');

      if (hasGoogleSearch) {
        if (isGemini2) {
          toolsList.add({'google_search': {}});
        } else {
          toolsList.add({'google_search_retrieval': {}});
        }
      }

      if (hasCodeExecution) {
        toolsList.add({'code_execution': {}});
      }

      if (functionDeclarations.isNotEmpty) {
        toolsList.add({'function_declarations': functionDeclarations});
      }

      body['tools'] = toolsList;
    }

    return body;
  }

  /// Parse response từ API
  AIResponse _parseResponse(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return AIResponse(text: '');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List?;

    final textParts = <String>[];
    final toolCalls = <AIToolCall>[];

    if (parts != null) {
      for (final part in parts) {
        final partMap = part as Map<String, dynamic>;

        // Xử lý text
        if (partMap.containsKey('text')) {
          textParts.add(partMap['text'] as String);
        }

        // Xử lý function call
        if (partMap.containsKey('functionCall')) {
          final functionCall = partMap['functionCall'] as Map<String, dynamic>;
          final name = functionCall['name'] as String;
          final args = functionCall['args'] as Map<String, dynamic>? ?? {};

          toolCalls.add(
            AIToolCall(
              id: 'call_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              arguments: args,
            ),
          );
        }
      }
    }

    final usageMetadata = json['usageMetadata'] as Map<String, dynamic>?;

    return AIResponse(
      text: textParts.join(''),
      toolCalls: toolCalls,
      finishReason: candidate['finishReason'] as String?,
      raw: {
        if (usageMetadata != null) ...{
          'promptTokenCount': usageMetadata['promptTokenCount'],
          'candidatesTokenCount': usageMetadata['candidatesTokenCount'],
          'totalTokenCount': usageMetadata['totalTokenCount'],
        },
      },
    );
  }

  /// Lấy danh sách models từ Gemini API
  Future<List<AIModel>> listModels() async {
    if (_apiKey.isEmpty) {
      return _getDefaultOptions();
    }

    try {
      final url = Uri.parse('$_baseUrl/v1beta/models?key=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final models = (json['models'] as List? ?? []);

        return models
            .map((m) => AIModel.fromJson((m as Map).cast<String, dynamic>()))
            .toList();
      }
    } catch (e) {
      // Nếu có lỗi, trả về danh sách mặc định
    }

    return _getDefaultOptions();
  }

  /// Danh sách models mặc định
  List<AIModel> _getDefaultOptions() {
    return [
      AIModel(
        name: 'gemini-pro',
        displayName: 'Gemini Pro',
        type: ModelType.chat,
        input: AIModelIO(text: true, image: true),
        output: AIModelIO(text: true),
        reasoning: true,
        contextWindow: 2097152,
      ),
      AIModel(
        name: 'gemini-flash',
        displayName: 'Gemini Flash',
        type: ModelType.chat,
        input: AIModelIO(text: true, image: true),
        output: AIModelIO(text: true),
        reasoning: false,
        contextWindow: 1048576,
      ),
    ];
  }
}
