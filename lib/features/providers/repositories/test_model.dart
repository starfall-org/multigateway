import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> testOpenAIModel(
  String modelId,
  String baseUrl,
  Map<String, String> headers,
) async {
  try {
    final Map<String, String> requestHeaders = Map.from(headers)
      ..addAll({'Content-Type': 'application/json'});
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: requestHeaders,
      body: jsonEncode({
        'model': modelId,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'max_tokens': 10,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'] != null && data['choices'].isNotEmpty;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> testAnthropicModel(
  String modelId,
  String baseUrl,
  Map<String, String> headers,
) async {
  try {
    // Check if baseUrl already ends with /messages or /v1/messages to avoid duplication
    String url = baseUrl;
    if (!url.endsWith('/v1/messages') && !url.endsWith('/messages')) {
      // Append standard path if missing.
      // Often generic base URLs are provided (e.g. https://api.anthropic.com)
      url = '$url/v1/messages';
    }

    final Map<String, String> requestHeaders = Map.from(headers)
      ..addAll({'Content-Type': 'application/json'});
    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: jsonEncode({
        'model': modelId,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'max_tokens': 10,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'] != null && data['content'].isNotEmpty;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> testGoogleGenAIModel(
  String modelId,
  String baseUrl,
  Map<String, String> headers,
) async {
  try {
    // Gemini API often puts the key in the query parameter 'key'
    // But we will respect the passed headers for 'x-goog-api-key' if present.
    // Base URL might need adjustment.
    // If baseUrl is the root (e.g. https://generativelanguage.googleapis.com), append path.

    // Construct the URL.
    // Usually: https://generativelanguage.googleapis.com/v1beta/models/{modelId}:generateContent

    String url = baseUrl;
    if (!url.contains(modelId)) {
      if (url.endsWith('/')) {
        url = '${url}v1beta/models/$modelId:generateContent';
      } else {
        url = '$url/v1beta/models/$modelId:generateContent';
      }
    }

    final Map<String, String> requestHeaders = Map.from(headers)
      ..addAll({'Content-Type': 'application/json'});
    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Hello'},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'] != null && data['candidates'].isNotEmpty;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> testOllamaModel(
  String modelId,
  String baseUrl,
  Map<String, String> headers,
) async {
  try {
    String url = baseUrl;
    if (!url.endsWith('/api/chat')) {
      // Handle trailing slash
      if (url.endsWith('/')) {
        url = '${url}api/chat';
      } else {
        url = '$url/api/chat';
      }
    }

    final Map<String, String> requestHeaders = Map.from(headers)
      ..addAll({'Content-Type': 'application/json'});
    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: jsonEncode({
        'model': modelId,
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] != null;
    }
    return false;
  } catch (e) {
    return false;
  }
}
