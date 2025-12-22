import 'package:flutter/material.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../../core/models/ai/ai_profile.dart';
import '../../../core/models/mcp/mcp_server.dart';

import '../../../core/translate.dart';

class MenuDrawer extends StatefulWidget {
  final ChatViewModel viewModel;

  const MenuDrawer({super.key, required this.viewModel});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();

  /// Static method to show the drawer as a modal bottom sheet
  static void showDrawer(BuildContext context, ChatViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => MenuDrawer(viewModel: viewModel),
    );
  }
}

class _MenuDrawerState extends State<MenuDrawer> {
  late AIProfile _profile;

  @override
  void initState() {
    super.initState();
    // Ensure we have MCP servers loaded
    widget.viewModel.loadMCPServers();
    // Create a local copy or just reference if we update directly via viewModel
    // Since AIProfile is immutable, we will create modified copies and send to updateProfile
    _profile = widget.viewModel.selectedProfile!;
  }

  void _updateProfile() {
    widget.viewModel.updateProfile(_profile);
    setState(() {}); // Rebuild UI
  }

  void _toggleBuiltInTool(String toolId, bool enabled) {
    final current = List<String>.from(_profile.activeBuiltInTools);
    if (enabled) {
      if (!current.contains(toolId)) current.add(toolId);
    } else {
      current.remove(toolId);
    }

    // Create new profile with updated tools
    _profile = AIProfile(
      id: _profile.id,
      name: _profile.name,
      config: _profile.config,
      profileConversations: _profile.profileConversations,
      conversationIds: _profile.conversationIds,
      activeMCPServers: _profile.activeMCPServers,
      activeBuiltInTools: current,
      persistChatSelection: _profile.persistChatSelection,
    );
    _updateProfile();
  }

  void _toggleMCPServer(String serverId, bool enabled) {
    final currentServers = List<ActiveMCPServer>.from(
      _profile.activeMCPServers,
    );

    if (enabled) {
      // Add server if not present, enable all tools by default or none?
      // Usually all tools.
      if (!currentServers.any((s) => s.id == serverId)) {
        // Find the server definition to get all tool names?
        // Or just add it and let the service handle tool discovery.
        // For simplicity, we add it with empty tools first or we need to know available tools.
        // The ActiveMCPServer model requires activeToolIds.
        // If we enable a server, we should probably enable its tools.
        final serverDef = widget.viewModel.mcpServers.firstWhere(
          (s) => s.id == serverId,
        );
        final allToolNames = serverDef.tools.map((t) => t.name).toList();

        currentServers.add(
          ActiveMCPServer(id: serverId, activeToolIds: allToolNames),
        );
      }
    } else {
      currentServers.removeWhere((s) => s.id == serverId);
    }

    _profile = AIProfile(
      id: _profile.id,
      name: _profile.name,
      config: _profile.config,
      profileConversations: _profile.profileConversations,
      conversationIds: _profile.conversationIds,
      activeMCPServers: currentServers,
      activeBuiltInTools: _profile.activeBuiltInTools,
      persistChatSelection: _profile.persistChatSelection,
    );
    _updateProfile();
  }

  void _toggleMCPTool(String serverId, String toolName, bool enabled) {
    final currentServers = List<ActiveMCPServer>.from(
      _profile.activeMCPServers,
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

      currentServers[index] = ActiveMCPServer(
        id: server.id,
        activeToolIds: currentTools,
      );

      _profile = AIProfile(
        id: _profile.id,
        name: _profile.name,
        config: _profile.config,
        profileConversations: _profile.profileConversations,
        conversationIds: _profile.conversationIds,
        activeMCPServers: currentServers,
        activeBuiltInTools: _profile.activeBuiltInTools,
        persistChatSelection: _profile.persistChatSelection,
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
            // Handle bar
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

            // Title
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
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  // Re-fetch profile in case it changed externally
                  if (widget.viewModel.selectedProfile != null) {
                    _profile = widget.viewModel.selectedProfile!;
                  }

                  return ListView(
                    children: [
                      // Section: Built-in Tools
                      _buildSectionHeader('Built-in Tools'),
                      _buildBuiltInToolTile(
                        'Google Search',
                        'google_search',
                        Icons.search,
                        'Search the web for up-to-date information.',
                      ),
                      _buildBuiltInToolTile(
                        'Code Execution',
                        'code_execution',
                        Icons.code,
                        'Execute Python code to solve complex problems.',
                      ),

                      const Divider(),

                      // Section: MCP Servers
                      _buildSectionHeader('MCP Servers'),
                      if (widget.viewModel.mcpServers.isEmpty)
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

                      ...widget.viewModel.mcpServers.map((server) {
                        return _buildMCPServerTile(server);
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBuiltInToolTile(
    String title,
    String id,
    IconData icon,
    String subtitle,
  ) {
    final isEnabled = _profile.activeBuiltInTools.contains(id);

    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      value: isEnabled,
      onChanged: (val) => _toggleBuiltInTool(id, val),
    );
  }

  Widget _buildMCPServerTile(MCPServer server) {
    final isActive = _profile.activeMCPServerIds.contains(server.id);

    return Column(
      children: [
        SwitchListTile(
          title: Text(server.name),
          subtitle: Text(server.httpConfig?.url ?? 'Stdio/Local Server'),
          secondary: const Icon(Icons.dns_outlined),
          value: isActive,
          onChanged: (val) => _toggleMCPServer(server.id, val),
        ),
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: server.tools.map((tool) {
                final activeServer = _profile.activeMCPServers.firstWhere(
                  (s) => s.id == server.id,
                );
                final isToolEnabled = activeServer.activeToolIds.contains(
                  tool.name,
                );

                return CheckboxListTile(
                  title: Text(tool.name, style: const TextStyle(fontSize: 14)),
                  subtitle: tool.description != null
                      ? Text(
                          tool.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                  value: isToolEnabled,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.only(left: 40, right: 16),
                  onChanged: (val) =>
                      _toggleMCPTool(server.id, tool.name, val ?? false),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
