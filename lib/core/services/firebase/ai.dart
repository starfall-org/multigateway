import 'dart:async';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../../models/ai_model.dart';
import '../../models/ai/ai_dto.dart';
import '../../models/provider.dart';

/// Google Gemini AI service sử dụng Firebase AI
/// Chỉ chia sẻ AIModel và DTO models, không chia sẻ các đối tượng nội bộ với providers khác
class GoogleAI {
  // Đối tượng Firebase AI - KHÔNG chia sẻ với providers khác
  final FirebaseAI _firebaseAI;
  final String _defaultModel;
  final Provider? _provider;

  GoogleAI({
    String defaultModel = 'gemini-1.5-flash',
    FirebaseApp? app,
    bool useVertexAI = false,
    Provider? provider,
  })  : _firebaseAI = useVertexAI
            ? FirebaseAI.vertexAI(app: app)
            : FirebaseAI.googleAI(app: app),
        _defaultModel = defaultModel,
        _provider = provider;

  /// Generate content với AIRequest (sử dụng DTO chung)
  Future<AIResponse> generate(AIRequest request) async {
    final model = _firebaseAI.generativeModel(
      model: request.model.isEmpty ? _defaultModel : request.model,
      generationConfig: GenerationConfig(
        temperature: request.temperature,
        maxOutputTokens: request.maxTokens,
      ),
    );

    final contents = _convertToFirebaseContents(request);
    final response = await model.generateContent(contents);

    return AIResponse(
      text: response.text ?? '',
      finishReason: response.candidates.firstOrNull?.finishReason?.name,
      raw: {
        'promptTokenCount': response.usageMetadata?.promptTokenCount,
        'candidatesTokenCount': response.usageMetadata?.candidatesTokenCount,
        'totalTokenCount': response.usageMetadata?.totalTokenCount,
      },
    );
  }

  /// Generate content với streaming (sử dụng DTO chung)
  Stream<AIResponse> generateStream(AIRequest request) async* {
    final model = _firebaseAI.generativeModel(
      model: request.model.isEmpty ? _defaultModel : request.model,
      generationConfig: GenerationConfig(
        temperature: request.temperature,
        maxOutputTokens: request.maxTokens,
      ),
    );

    final contents = _convertToFirebaseContents(request);
    final stream = model.generateContentStream(contents);

    await for (final chunk in stream) {
      final text = chunk.text ?? '';
      if (text.isNotEmpty) {
        yield AIResponse(text: text);
      }
    }
  }

  /// Convert AIRequest sang Firebase Content format
  List<Content> _convertToFirebaseContents(AIRequest request) {
    final contents = <Content>[];

    for (final msg in request.messages) {
      final parts = <Part>[];

      for (final content in msg.content) {
        switch (content.type) {
          case AIContentType.text:
            if (content.text?.isNotEmpty ?? false) {
              parts.add(TextPart(content.text!));
            }
            break;
          case AIContentType.image:
            if (content.dataBase64 != null) {
              final bytes = base64Decode(content.dataBase64!);
              parts.add(InlineDataPart(
                content.mimeType ?? 'image/jpeg',
                bytes,
              ));
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
            final bytes = base64Decode(img.dataBase64!);
            parts.add(InlineDataPart(
              img.mimeType ?? 'image/jpeg',
              bytes,
            ));
          }
        }
      }

      if (parts.isNotEmpty) {
        contents.add(Content(
          msg.role == 'user' ? 'user' : 'model',
          parts,
        ));
      }
    }

    return contents;
  }

  /// Lấy danh sách models từ Gemini API
  /// Firebase AI không có API list models, nên gọi trực tiếp HTTP API
  Future<List<AIModel>> listModels() async {
    if (_provider == null || _provider.apiKey.isEmpty) {
      // Trả về danh sách hardcoded nếu không có provider
      return _getDefaultModels();
    }

    try {
      final url = Uri.parse(
        '${_provider.baseUrl}/v1beta/models?key=${_provider.apiKey}',
      );
      
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
    
    return _getDefaultModels();
  }

  /// Danh sách models mặc định
  List<AIModel> _getDefaultModels() {
    return [
      AIModel(
        name: 'gemini-1.5-pro',
        type: ModelType.textGeneration,
        input: [ModelIOType.text, ModelIOType.image],
        output: [ModelIOType.text],
        tool: true,
        reasoning: true,
        contextWindow: 2097152,
      ),
      AIModel(
        name: 'gemini-1.5-flash',
        type: ModelType.textGeneration,
        input: [ModelIOType.text, ModelIOType.image],
        output: [ModelIOType.text],
        tool: true,
        reasoning: false,
        contextWindow: 1048576,
      ),
      AIModel(
        name: 'gemini-2.0-flash-exp',
        type: ModelType.textGeneration,
        input: [ModelIOType.text, ModelIOType.image],
        output: [ModelIOType.text],
        tool: true,
        reasoning: true,
        contextWindow: 1048576,
      ),
      AIModel(
        name: 'gemini-pro-vision',
        type: ModelType.textGeneration,
        input: [ModelIOType.text, ModelIOType.image],
        output: [ModelIOType.text],
        tool: false,
        reasoning: false,
        contextWindow: 32768,
      ),
      AIModel(
        name: 'text-embedding-004',
        type: ModelType.embedding,
        input: [ModelIOType.text],
        output: [ModelIOType.text],
        tool: false,
        reasoning: false,
        contextWindow: 2048,
      ),
    ];
  }
}