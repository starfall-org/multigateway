import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/core/profile/profile.dart';

/// Tile cho MCP server với danh sách tools
class McpServerTile extends StatelessWidget {
  final McpServer server;
  final ChatProfile profile;
  final Function(String serverId, bool enabled) onServerToggle;
  final Function(String serverId, String toolName, bool enabled) onToolToggle;

  const McpServerTile({
    super.key,
    required this.server,
    required this.profile,
    required this.onServerToggle,
    required this.onToolToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = profile.activeMcpServerIds.contains(server.id);

    return Column(
      children: [
        SwitchListTile(
          title: Text(server.name),
          subtitle: Text(server.httpConfig?.url ?? 'Stdio/Local Server'),
          secondary: const Icon(Icons.dns_outlined),
          value: isActive,
          onChanged: (val) => onServerToggle(server.id, val),
        ),
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: server.tools.map((tool) {
                final activeServer = profile.activeMcpServers.firstWhere(
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
                      onToolToggle(server.id, tool.name, val ?? false),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}