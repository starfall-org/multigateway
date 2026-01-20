import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/presentation/controllers/home_controller.dart';
import 'package:multigateway/features/home/presentation/widgets/mcp_item_tile.dart';
import 'package:multigateway/features/home/presentation/widgets/section_header.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

class QuickActionsSheet extends StatefulWidget {
  final ChatController controller;
  final ScrollController scrollController;

  const QuickActionsSheet({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  @override
  State<QuickActionsSheet> createState() => _QuickActionsSheetState();

  static void show(BuildContext context, ChatController controller) {
    CustomBottomSheet.show(
      context,
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      builder: (ctx, scrollController) => QuickActionsSheet(
        controller: controller,
        scrollController: scrollController,
      ),
    );
  }
}

class _QuickActionsSheetState extends State<QuickActionsSheet> {
  late ChatProfile _profile;

  @override
  void initState() {
    super.initState();
    widget.controller.loadMcpClients();
    _profile = widget.controller.profile.selectedProfile.value!;
  }

  void _updateProfile() {
    widget.controller.updateProfile(_profile);
    setState(() {});
  }

  void _toggleMcpItem(String mcpId, bool enabled) {
    final currentMcp = List<ActiveMcp>.from(_profile.activeMcp);

    if (enabled) {
      if (!currentMcp.any((s) => s.id == mcpId)) {
        final mcpTools = widget.controller.profile.mcpTools.value.firstWhere(
          (s) => s.id == mcpId,
        );

        final allToolNames = mcpTools.tools
            .map((t) => t['name'] as String)
            .toList();

        currentMcp.add(ActiveMcp(id: mcpId, activeToolNames: allToolNames));
      }
    } else {
      currentMcp.removeWhere((s) => s.id == mcpId);
    }

    _profile = ChatProfile(
      id: _profile.id,
      name: _profile.name,
      config: _profile.config,
      activeMcp: currentMcp,
      activeModelTools: _profile.activeModelTools,
    );
    _updateProfile();
  }

  void _toggleMcpTool(String mcpId, String toolName, bool enabled) {
    final currentMcp = List<ActiveMcp>.from(_profile.activeMcp);
    final index = currentMcp.indexWhere((s) => s.id == mcpId);

    if (index != -1) {
      final server = currentMcp[index];
      final currentTools = List<String>.from(server.activeToolNames);

      if (enabled) {
        if (!currentTools.contains(toolName)) currentTools.add(toolName);
      } else {
        currentTools.remove(toolName);
      }

      currentMcp[index] = ActiveMcp(
        id: server.id,
        activeToolNames: currentTools,
      );

      _profile = ChatProfile(
        id: _profile.id,
        name: _profile.name,
        config: _profile.config,
        activeMcp: currentMcp,
        activeModelTools: _profile.activeModelTools,
      );
      _updateProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            tl('Tools Configuration'),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(),
        Expanded(
          child: Watch((context) {
            final selectedProfile =
                widget.controller.profile.selectedProfile.value;
            if (selectedProfile != null) {
              _profile = selectedProfile;
            }

            final mcpItems = widget.controller.profile.mcpItems.value;

            return ListView(
              controller: widget.scrollController,
              children: [
                const SectionHeader(title: 'MCP Servers'),
                if (mcpItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tl('No MCP servers configured.'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ...mcpItems.map((client) {
                  return McpItemTile(
                    client: client,
                    toolsList: widget.controller.profile.mcpTools.value
                        .firstWhere((t) => t.id == client.id),
                    profile: _profile,
                    onServerToggle: _toggleMcpItem,
                    onToolToggle: _toggleMcpTool,
                  );
                }),
              ],
            );
          }),
        ),
      ],
    );
  }
}
