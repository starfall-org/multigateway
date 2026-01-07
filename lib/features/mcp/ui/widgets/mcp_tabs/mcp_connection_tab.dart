import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/ui/widgets/mcp_controller_provider.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Tab cấu hình connection cho MCP server
class McpConnectionTab extends StatelessWidget {
  const McpConnectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = McpControllerProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection Settings
        if (controller.selectedTransport != McpProtocol.stdio) ...[
          Text(
            tl('Connection Settings'),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Server URL
          CustomTextField(
            controller: controller.urlController,
            label: tl('Server URL'),
            hint: _getUrlHint(controller.selectedTransport),
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 24),

          // Headers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tl('HTTP Headers'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: controller.addHeader,
                tooltip: tl('Add Header'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headers List
          if (controller.headers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tl(
                        'No headers configured. Add headers for authentication or other custom needs.',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...controller.headers.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${tl('Header')} ${index + 1}',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () => controller.removeHeader(index),
                              tooltip: tl('Remove Header'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: header.key,
                                label: tl('Header Name'),
                                hint: 'Authorization, Content-Type, etc.',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: header.value,
                                label: tl('Header Value'),
                                hint: 'Bearer token, application/json, etc.',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ] else ...[
          // STDIO Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tl('STDIO Transport'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tl(
                    'STDIO transport is used for local MCP servers that communicate through standard input/output streams. This is typically used for command-line tools and local processes.',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getUrlHint(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return 'https://example.com/mcp/sse';
      case McpProtocol.streamableHttp:
        return 'https://example.com/mcp/';
      case McpProtocol.stdio:
        return '';
    }
  }
}