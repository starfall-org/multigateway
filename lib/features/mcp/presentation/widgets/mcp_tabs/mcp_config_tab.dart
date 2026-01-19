import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_controller_provider.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Tab cấu hình MCP server
class McpConfigTab extends StatelessWidget {
  const McpConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = McpControllerProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Transport Type Selection
        CommonDropdown<McpProtocol>(
          value: controller.selectedTransport.value,
          label: tl('Transport Type'),
          options: McpProtocol.values.map((transport) {
            return DropdownOption<McpProtocol>(
              value: transport,
              label: _getTransportLabel(transport),
              icon: _getTransportIcon(transport),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateTransport(value);
            }
          },
        ),

        const SizedBox(height: 24),

        // Basic Information
        Text(
          tl('Basic Information'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Server Name
        CustomTextField(
          controller: controller.nameController,
          label: tl('Server Name'),
          hint: tl('Enter a descriptive name for this MCP server'),
          prefixIcon: Icons.dns_outlined,
        ),

        const SizedBox(height: 24),

        // Connection Settings
        if (controller.selectedTransport.value != McpProtocol.stdio) ...[
          Text(
            tl('Connection Settings'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Server URL
          CustomTextField(
            controller: controller.urlController,
            label: tl('Server URL'),
            hint: _getUrlHint(controller.selectedTransport.value),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: controller.addHeader,
                tooltip: tl('Add Header'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headers List (Signals Watch)
          Watch((context) {
            return Column(
              children: controller.headers.value.asMap().entries.map((entry) {
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
              }).toList(),
            );
          }),
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

  String _getTransportLabel(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return tl('Server-Sent Events (SSE)');
      case McpProtocol.streamableHttp:
        return tl('Streamable HTTP');
      case McpProtocol.stdio:
        return tl('Standard I/O (STDIO)');
    }
  }

  Icon _getTransportIcon(McpProtocol transport) {
    switch (transport) {
      case McpProtocol.sse:
        return const Icon(Icons.stream);
      case McpProtocol.streamableHttp:
        return const Icon(Icons.http);
      case McpProtocol.stdio:
        return const Icon(Icons.terminal);
    }
  }
}
