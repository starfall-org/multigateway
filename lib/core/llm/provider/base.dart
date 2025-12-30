import '../models/api/api.dart';
import '../models/llm_model/base.dart';
export '../models/api/api.dart';
export '../models/llm_model/base.dart';


abstract class AIBaseApi {
  final String apiKey;
  final String baseUrl;
  final Map<String, String> headers;

  const AIBaseApi({
    this.apiKey = '',
    required this.baseUrl,
    this.headers = const {},
  });

  Map<String, String> getHeaders({Map<String, String> overrides = const {}}) {
    final result = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
      ...headers,
      ...overrides,
    };
    return result;
  }

  Uri uri(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Uri.parse(pathOrUrl);
    }
    final normalized = pathOrUrl.startsWith('/') ? pathOrUrl : '/$pathOrUrl';
    return Uri.parse('$baseUrl$normalized');
  }

  Future<AIResponse> generate(AIRequest request);

  Stream<AIResponse>? generateStream(AIRequest request) => null;

  Future<List<AIModel>> listModels();

  Future<dynamic> embed({
    required String model,
    required dynamic input,
    Map<String, dynamic> options = const {},
  });
}

/// Helpers
