import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_controller_provider.dart';

/// Tab thông tin về MCP transport
class McpInfoTab extends StatelessWidget {
  const McpInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = McpControllerProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTransportInfoCard(context, controller.selectedTransport as McpProtocol),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTransportInfoCard(BuildContext context, McpProtocol transport) {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (transport) {
      case McpProtocol.sse:
        title = tl('Server-Sent Events (SSE)');
        description = tl(
          'SSE provides real-time communication over HTTP. Best for servers that need to send continuous updates to clients.',
        );
        icon = Icons.stream;
        color = Theme.of(context).colorScheme.primary;
        break;
      case McpProtocol.streamableHttp:
        title = tl('Streamable HTTP');
        description = tl(
          'Streamable HTTP is the recommended transport for new MCP implementations. It provides efficient bidirectional communication.',
        );
        icon = Icons.http;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case McpProtocol.stdio:
        title = tl('Standard I/O (STDIO)');
        description = tl(
          'STDIO transport communicates through standard input/output. Perfect for local command-line tools and processes.',
        );
        icon = Icons.terminal;
        color = Theme.of(context).colorScheme.secondary;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}