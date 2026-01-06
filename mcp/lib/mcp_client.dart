import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/mcp_server.dart';
import 'models/mcp_jsonrpc.dart';
import 'models/mcp_request.dart';
import 'models/mcp_response.dart';

class MCPService {
  /// Fetches the list of tools from an MCP server.
  Future<List<McpTool>> fetchTools(McpServer server) async {
    final response = await _sendRequest(
      server,
      (id) => ListToolsRequest(id: id),
    );

    if (response.result != null) {
      final result = ListToolsResult.fromJson(response.result);
      return result.tools;
    }
    return [];
  }

  /// Calls a tool on the MCP server.
  Future<CallToolResult> callTool(
    McpServer server,
    String name,
    Map<String, dynamic> arguments,
  ) async {
    final response = await _sendRequest(
      server,
      (id) => CallToolRequest(id: id, name: name, arguments: arguments),
    );

    if (response.result != null) {
      return CallToolResult.fromJson(response.result);
    }
    throw Exception('Failed to call tool: ${response.error?.message}');
  }

  /// Fetches the list of resources from an MCP server.
  Future<List<McpResource>> fetchResources(McpServer server) async {
    final response = await _sendRequest(
      server,
      (id) => ListResourcesRequest(id: id),
    );

    if (response.result != null) {
      final result = ListResourcesResult.fromJson(response.result);
      return result.resources;
    }
    return [];
  }

  /// Reads a resource from the MCP server.
  Future<List<McpResourceContent>> readResource(
    McpServer server,
    String uri,
  ) async {
    final response = await _sendRequest(
      server,
      (id) => ReadResourceRequest(id: id, uri: uri),
    );

    if (response.result != null) {
      final result = ReadResourceResult.fromJson(response.result);
      return result.contents;
    }
    return [];
  }

  /// Internal helper to send a request based on server transport
  Future<MCPResponse> _sendRequest(
    McpServer server,
    MCPRequest Function(int id) requestBuilder,
  ) async {
    if (server.httpConfig == null) {
      throw Exception(
        'HTTP Config missing for transport ${server.transport.name}',
      );
    }

    final headers = server.httpConfig!.headers ?? {};
    final url = server.httpConfig!.url;

    try {
      if (server.transport == MCPTransportType.sse) {
        return await _sendRequestSse(url, headers, requestBuilder);
      } else {
        return await _sendRequestPost(url, headers, requestBuilder(1));
      }
    } catch (e) {
      throw Exception('MCP Request failed: $e');
    }
  }

  Future<MCPResponse> _sendRequestPost(
    String url,
    Map<String, String> headers,
    MCPRequest request,
  ) async {
    final requestHeaders = Map<String, String>.from(headers);
    requestHeaders.putIfAbsent('Content-Type', () => 'application/json');
    // Streamable HTTP servers may require both content types
    requestHeaders.putIfAbsent('Accept', () => 'application/json, text/event-stream');

    final response = await http.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mcpResponse = MCPResponse.fromJson(data);
      if (mcpResponse.error != null) {
        throw Exception('MCP Error: ${mcpResponse.error!.message}');
      }
      return mcpResponse;
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  Future<MCPResponse> _sendRequestSse(
    String url,
    Map<String, String> headers,
    MCPRequest Function(int id) requestBuilder,
  ) async {
    final client = http.Client();
    final requestHeaders = Map<String, String>.from(headers);
    requestHeaders['Accept'] = 'text/event-stream';

    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(requestHeaders);

    final completer = Completer<MCPResponse>();

    try {
      final response = await client.send(request);

      final streamSubscription = response.stream
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())
          .listen((line) async {
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();

              Uri uri = Uri.parse(url);
              String calculatedPostUrl = data.startsWith('http')
                  ? data
                  : uri.resolve(data).toString();

              if (!completer.isCompleted) {
                try {
                  final resp = await _sendRequestPost(
                    calculatedPostUrl,
                    headers,
                    requestBuilder(1),
                  );
                  completer.complete(resp);
                } catch (e) {
                  completer.completeError(e);
                }
              }
            }
          });

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
}
