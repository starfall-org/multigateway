import 'package:mcp/models/mcp_jsonrpc.dart';

/// Client initialization request
class InitializeRequest extends MCPRequest {
  InitializeRequest({
    required super.id,
    required String protocolVersion,
    required Map<String, dynamic> capabilities,
    required Map<String, dynamic> clientInfo,
  }) : super(
         method: 'initialize',
         params: {
           'protocol_version': protocolVersion,
           'capabilities': capabilities,
           'client_info': clientInfo,
         },
       );
}

/// Request to list available tools
class ListToolsRequest extends MCPRequest {
  ListToolsRequest({required super.id, String? cursor})
    : super(
        method: 'tools/list',
        params: {if (cursor != null) 'cursor': cursor},
      );
}

/// Request to call a specific tool
class CallToolRequest extends MCPRequest {
  CallToolRequest({
    required super.id,
    required String name,
    Map<String, dynamic>? arguments,
  }) : super(
         method: 'tools/call',
         params: {'name': name, if (arguments != null) 'arguments': arguments},
       );
}

/// Request to list available resources
class ListResourcesRequest extends MCPRequest {
  ListResourcesRequest({required super.id, String? cursor})
    : super(
        method: 'resources/list',
        params: {if (cursor != null) 'cursor': cursor},
      );
}

/// Request to read a specific resource
class ReadResourceRequest extends MCPRequest {
  ReadResourceRequest({required super.id, required String uri})
    : super(method: 'resources/read', params: {'uri': uri});
}

/// Request to list available prompts
class ListPromptsRequest extends MCPRequest {
  ListPromptsRequest({required super.id, String? cursor})
    : super(
        method: 'prompts/list',
        params: {if (cursor != null) 'cursor': cursor},
      );
}

/// Request to get a specific prompt
class GetPromptRequest extends MCPRequest {
  GetPromptRequest({
    required super.id,
    required String name,
    Map<String, dynamic>? arguments,
  }) : super(
         method: 'prompts/get',
         params: {'name': name, if (arguments != null) 'arguments': arguments},
       );
}

/// Notification sent by the client after initialization is complete
class InitializedNotification extends MCPNotification {
  InitializedNotification() : super(method: 'notifications/initialized');
}

/// Notification to set logging level
class SetLevelNotification extends MCPNotification {
  SetLevelNotification({required String level})
    : super(method: 'logging/setLevel', params: {'level': level});
}

/// Ping request to check server liveness
class PingRequest extends MCPRequest {
  PingRequest({required super.id}) : super(method: 'ping');
}
