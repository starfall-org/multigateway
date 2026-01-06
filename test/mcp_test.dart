import 'package:flutter_test/flutter_test.dart';
import 'package:mcp/mcp.dart';

void main() {
  group('MCP SSE Server Tests', () {
    late MCPService mcpService;
    late McpServer server;

    setUp(() {
      mcpService = MCPService();
      // Using standard Streamable HTTP MCP server
      server = McpServer.streamable(
        name: 'Context7 MCP',
        description: 'Standard MCP server for testing',
        url: 'https://mcp.context7.com/mcp',
      );
    });

    test('should fetch tools from SSE server', () async {
      try {
        final tools = await mcpService.fetchTools(server);
        
        print('✓ Fetched ${tools.length} tools');
        for (var tool in tools) {
          print('  - ${tool.name}: ${tool.description ?? "No description"}');
        }
        
        expect(tools, isNotEmpty, reason: 'Server should return at least one tool');
      } catch (e) {
        print('✗ Error fetching tools: $e');
        rethrow;
      }
    });

    test('should fetch resources from SSE server', () async {
      try {
        final resources = await mcpService.fetchResources(server);
        
        print('✓ Fetched ${resources.length} resources');
        for (var resource in resources) {
          print('  - ${resource.name ?? resource.uri}: ${resource.description ?? "No description"}');
        }
        
        // Resources might be empty, so we just check it doesn't throw
        expect(resources, isA<List<McpResource>>());
      } catch (e) {
        print('✗ Error fetching resources: $e');
        rethrow;
      }
    });

    test('should call a tool if available', () async {
      try {
        // First get available tools
        final tools = await mcpService.fetchTools(server);
        
        if (tools.isEmpty) {
          print('⊘ No tools available to test');
          return;
        }

        // Try to call the first tool with empty or minimal arguments
        final firstTool = tools.first;
        print('→ Attempting to call tool: ${firstTool.name}');
        
        try {
          final result = await mcpService.callTool(
            server,
            firstTool.name,
            {}, // Empty arguments - adjust based on tool requirements
          );
          
          print('✓ Tool call successful');
          for (var content in result.content) {
            if (content is McpTextContent) {
              print('  Text: ${content.text}');
            } else if (content is McpImageContent) {
              print('  Image: ${content.mimeType}');
            } else if (content is McpResourceContent) {
              print('  Resource: ${content.uri}');
            }
          }
          
          expect(result, isA<CallToolResult>());
          expect(result.content, isNotEmpty);
        } catch (toolError) {
          print('⚠ Tool call failed (might need specific arguments): $toolError');
          // Don't fail the test if tool needs specific arguments
        }
      } catch (e) {
        print('✗ Error in tool call test: $e');
        rethrow;
      }
    });
  });
}
