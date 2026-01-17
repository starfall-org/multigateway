import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_controller_provider.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

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
          labelText: tl('Transport Type'),
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
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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
      ],
    );
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