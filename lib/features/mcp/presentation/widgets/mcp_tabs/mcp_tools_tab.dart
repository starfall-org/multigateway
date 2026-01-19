import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/mcp/presentation/widgets/mcp_controller_provider.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';
import 'package:signals_flutter/signals_flutter.dart';

class McpToolsTab extends StatefulWidget {
  const McpToolsTab({super.key});

  @override
  State<McpToolsTab> createState() => _McpToolsTabState();
}

class _McpToolsTabState extends State<McpToolsTab> {
  @override
  void initState() {
    super.initState();
    // Fetch tools when the tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      McpControllerProvider.of(context).fetchTools();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = McpControllerProvider.of(context);

    return Watch((context) {
      if (controller.isLoadingTools.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final error = controller.toolsError.value;
      if (error != null) {
        return EmptyState(
          icon: Icons.error_outline,
          message: tl('Error loading tools'),
          subMessage: error,
          actionLabel: tl('Retry'),
          onAction: () => controller.fetchTools(),
        );
      }

      final tools = controller.mcpTools.value;
      if (tools.isEmpty) {
        return EmptyState(
          icon: Icons.build_circle_outlined,
          message: tl('No tools found'),
          subMessage: tl(
            'Make sure the server is running and the URL is correct',
          ),
          actionLabel: tl('Refresh'),
          onAction: () => controller.fetchTools(),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final name = tool['name'] ?? tl('Unknown Tool');
          final description =
              tool['description'] ?? tl('No description available');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: Text(name),
              subtitle: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
            ),
          );
        },
      );
    });
  }
}
