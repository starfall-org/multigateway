import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/presentation/controllers/home_controller.dart';
import 'package:multigateway/features/home/presentation/widgets/quick_actions_widgets/built_in_tool_tile.dart';
import 'package:multigateway/features/home/presentation/widgets/quick_actions_widgets/mcp_server_tile.dart';
import 'package:multigateway/features/home/presentation/widgets/quick_actions_widgets/section_header.dart';
import 'package:signals_flutter/signals_flutter.dart';

class QuickActionsSheet extends StatefulWidget {
  final ChatController controller;

  const QuickActionsSheet({super.key, required this.controller});

  @override
  State<QuickActionsSheet> createState() => _QuickActionsSheetState();

  static void show(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => QuickActionsSheet(controller: controller),
    );
  }
}

class _QuickActionsSheetState extends State<QuickActionsSheet> {
  late ChatProfile _profile;

  @override
  void initState() {
    super.initState();
    widget.controller.loadMcpServers();
    _profile = widget.controller.profile.selectedProfile.value!;
  }

  void _updateProfile() {
    widget.controller.updateProfile(_profile);
    setState(() {});
  }

  void _toggleBuiltInTool(String toolId, bool enabled) {
    final current = List<String>.from(_profile.activeBuiltInTools);
    if (enabled) {
      if (!current.contains(toolId)) current.add(toolId);
    } else {
      current.remove(toolId);
    }

    _profile = ChatProfile(
      id: _profile.id,
      name: _profile.name,
      config: _profile.config,
      activeMcpServers: _profile.activeMcpServers,
      activeBuiltInTools: current,
    );
    _updateProfile();
  }

  void _toggleMcpServer(String serverId, bool enabled) {
    final currentServers = List<ActiveMcpServer>.from(
      _profile.activeMcpServers,
    );

    if (enabled) {
      if (!currentServers.any((s) => s.id == serverId)) {
        final serverDef = widget.controller.profile.mcpServers.value.firstWhere(
          (s) => s.id == serverId,
        );
        final allToolNames = serverDef.tools.map((t) => t.name).toList();

        currentServers.add(
          ActiveMcpServer(id: serverId, activeToolIds: allToolNames),
        );
      }
    } else {
      currentServers.removeWhere((s) => s.id == serverId);
    }

    _profile = ChatProfile(
      id: _profile.id,
      name: _profile.name,
      config: _profile.config,
      activeMcpServers: currentServers,
      activeBuiltInTools: _profile.activeBuiltInTools,
    );
    _updateProfile();
  }

  void _toggleMcpTool(String serverId, String toolName, bool enabled) {
    final currentServers = List<ActiveMcpServer>.from(
      _profile.activeMcpServers,
    );
    final index = currentServers.indexWhere((s) => s.id == serverId);

    if (index != -1) {
      final server = currentServers[index];
      final currentTools = List<String>.from(server.activeToolIds);

      if (enabled) {
        if (!currentTools.contains(toolName)) currentTools.add(toolName);
      } else {
        currentTools.remove(toolName);
      }

      currentServers[index] = ActiveMcpServer(
        id: server.id,
        activeToolIds: currentTools,
      );

      _profile = ChatProfile(
        id: _profile.id,
        name: _profile.name,
        config: _profile.config,
        activeMcpServers: currentServers,
        activeBuiltInTools: _profile.activeBuiltInTools,
      );
      _updateProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                tl('Tools Configuration'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

                final model = widget.controller.model.selectedLlmModel;
                final origin = model?.origin;
                final tools = origin?.builtInTools;
                final mcpServers = widget.controller.profile.mcpServers.value;

                return ListView(
                  children: [
                    if (tools != null &&
                        (tools.googleSearch ||
                            tools.codeExecution ||
                            tools.urlContext)) ...[
                      const SectionHeader(title: 'Built-in Tools'),
                      if (tools.googleSearch)
                        BuiltInToolTile(
                          title: 'Google Search',
                          id: 'google_search',
                          icon: Icons.search,
                          subtitle:
                              'Search the web for up-to-date information.',
                          isEnabled: _profile.activeBuiltInTools.contains(
                            'google_search',
                          ),
                          onChanged: (val) =>
                              _toggleBuiltInTool('google_search', val),
                        ),
                      if (tools.codeExecution)
                        BuiltInToolTile(
                          title: 'Code Execution',
                          id: 'code_execution',
                          icon: Icons.code,
                          subtitle:
                              'Execute Python code to solve complex problems.',
                          isEnabled: _profile.activeBuiltInTools.contains(
                            'code_execution',
                          ),
                          onChanged: (val) =>
                              _toggleBuiltInTool('code_execution', val),
                        ),
                      if (tools.urlContext)
                        BuiltInToolTile(
                          title: 'URL Context',
                          id: 'url_context',
                          icon: Icons.link,
                          subtitle:
                              'Access and read content from specific URLs.',
                          isEnabled: _profile.activeBuiltInTools.contains(
                            'url_context',
                          ),
                          onChanged: (val) =>
                              _toggleBuiltInTool('url_context', val),
                        ),
                      const Divider(),
                    ],
                    const SectionHeader(title: 'MCP Servers'),
                    if (mcpServers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          tl('No MCP servers configured.'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ...mcpServers.map((server) {
                      return McpServerTile(
                        server: server,
                        profile: _profile,
                        onServerToggle: _toggleMcpServer,
                        onToolToggle: _toggleMcpTool,
                      );
                    }),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
