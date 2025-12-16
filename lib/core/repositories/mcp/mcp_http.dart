import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/mcp/mcp_core.dart';

/// Fetches the list of tools from an MCP server.
/// Supports both Streamable (Direct POST) and SSE (Handshake + POST) transports.
Future<List<MCPTool>> fetchMcpTools(
  String url,
  MCPTransportType method, {
  Map<String, String>? headers,
}) async {
  final Map<String, String> requestHeaders = Map.from(headers ?? {});

  try {
    if (method == MCPTransportType.sse) {
      return await _fetchToolsSse(url, requestHeaders);
    } else {
      // Default to Streamable/HTTP POST
      return await _fetchToolsPost(url, requestHeaders);
    }
  } catch (e) {
    throw Exception('Failed to fetch tools: $e');
  }
}

Future<List<MCPTool>> _fetchToolsPost(
  String url,
  Map<String, String> headers,
) async {
  headers.putIfAbsent('Content-Type', () => 'application/json');

  final payload = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list",
    "params": {},
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
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
  final request = http.Request('GET', Uri.parse(url));
  request.headers.addAll(headers);
  request.headers['Accept'] = 'text/event-stream';

  final completer = Completer<List<MCPTool>>();
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
            // Check if this data corresponds to the endpoint event (simplification)
            // Ideally we track state. assuming first data we see after connection is the endpoint for now or check previous event line.

            // Use the relative or absolute URL provided
            Uri uri = Uri.parse(url);
            if (data.startsWith('http')) {
              postUrl = data;
            } else {
              postUrl = uri.resolve(data).toString();
            }

            // Once we have the POST URL, we can make the request
            if (postUrl != null && !completer.isCompleted) {
              try {
                final tools = await _fetchToolsPost(postUrl!, headers);
                completer.complete(tools);
              } catch (e) {
                completer.completeError(e);
              }
            }
          }
        });

    // Timeout if we don't get the endpoint quickly
    // Note: This is a simplified "fetch" that doesn't keep the connection open long term.
    // In a real app, you'd keep this SSE connection valid.
    Future.delayed(const Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        streamSubscription.cancel();
        completer.completeError(Exception('Timeout waiting for SSE endpoint'));
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
      return (result['tools'] as List).map((t) => MCPTool.fromJson(t)).toList();
    }
  }
  if (data.containsKey('error')) {
    throw Exception('MCP Error: ${data['error']['message']}');
  }
  return [];
}
