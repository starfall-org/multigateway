abstract class LlmProviderBase {
  final String apiKey;
  final String baseUrl;
  final Map<String, String> headers;

  const LlmProviderBase({
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
}
