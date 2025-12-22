import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/models/mcp/mcp_server.dart';

class MCPService {
  /// Fetches the list of tools from an MCP server.
  /// Supports both Streamable (Direct POST) and SSE (Handshake + POST) transports.
  Future<List<MCPTool>> fetchTools(MCPServer server) async {
    if (server.httpConfig == null) {
      throw Exception(
        'HTTP Config missing for transport ${server.transport.name}',
      );
    }

    final headers = server.httpConfig!.headers ?? {};
    final url = server.httpConfig!.url;

    try {
      if (server.transport == MCPTransportType.sse) {
        return await _fetchToolsSse(url, headers);
      } else {
        // Default to Streamable/HTTP POST
        return await _fetchToolsPost(url, headers);
      }
    } catch (e) {
      throw Exception('Failed to fetch tools: $e');
    }
  }

  Future<List<MCPTool>> _fetchToolsPost(
    String url,
    Map<String, String> headers,
  ) async {
    final requestHeaders = Map<String, String>.from(headers);
    requestHeaders.putIfAbsent('Content-Type', () => 'application/json');

    final payload = {
      "jsonrpc": "2.0",
      "id": 1,
      "method": "tools/list",
      "params": {},
    };

    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _parseToolsFromResponse(data);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  Future<List<MCPTool>> _fetchToolsSse(
    String url,
    Map<String, String> headers,
  ) async {
    // SSE Handshake:
    // 1. Connect to SSE endpoint to get the "endpoint" event which contains the POST URL.
    // 2. Use that URL to send the tools/list request.

    final client = http.Client();
    final requestHeaders = Map<String, String>.from(headers);
    requestHeaders['Accept'] = 'text/event-stream';

    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(requestHeaders);

    final completer = Completer<List<MCPTool>>();
    // ignore: unused_local_variable
    String? postUrl;

    try {
      final response = await client.send(request);

      // Listen to the stream to find the endpoint
      final streamSubscription = response.stream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())
          .listen((line) async {
            if (line.startsWith('event: endpoint')) {
              // The next line(s) should be data: ...
            } else if (line.startsWith('data: ')) {
              // Simple parsing for the endpoint URL
              // Spec says: event: endpoint \n data: /mcp/messages?sessionId=...
              final data = line.substring(6).trim();

              // Use the relative or absolute URL provided
              Uri uri = Uri.parse(url);
              // Calculate postUrl
              String calculatedPostUrl;
              if (data.startsWith('http')) {
                calculatedPostUrl = data;
              } else {
                calculatedPostUrl = uri.resolve(data).toString();
              }
              postUrl = calculatedPostUrl;

              // Once we have the POST URL, we can make the request
              if (!completer.isCompleted) {
                try {
                  final tools = await _fetchToolsPost(
                    calculatedPostUrl,
                    headers,
                  );
                  completer.complete(tools);
                } catch (e) {
                  completer.completeError(e);
                }
              }
            }
          });

      // Timeout if we don't get the endpoint quickly
      Future.delayed(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          streamSubscription.cancel();
          completer.completeError(
            Exception('Timeout waiting for SSE endpoint'),
          );
        }
      });

      final results = await completer.future;
      await streamSubscription.cancel();
      client.close();
      return results;
    } catch (e) {
      client.close();
      rethrow;
    }
  }

  List<MCPTool> _parseToolsFromResponse(Map<String, dynamic> data) {
    if (data.containsKey('result') && data['result'] != null) {
      final result = data['result'];
      if (result is Map && result.containsKey('tools')) {
        return (result['tools'] as List)
            .map((t) => MCPTool.fromJson(t))
            .toList();
      }
    }
    if (data.containsKey('error')) {
      throw Exception('MCP Error: ${data['error']['message']}');
    }
    return [];
  }
}
