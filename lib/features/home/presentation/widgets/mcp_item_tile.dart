import 'package:flutter/material.dart';
import 'package:multigateway/core/core.dart';

/// Tile cho MCP server với danh sách tools
class McpItemTile extends StatelessWidget {
  final McpInfo client;
  final McpToolsList toolsList;
  final ChatProfile profile;
  final Function(String serverId, bool enabled) onServerToggle;
  final Function(String serverId, String toolName, bool enabled) onToolToggle;

  const McpItemTile({
    super.key,
    required this.client,
    required this.toolsList,
    required this.profile,
    required this.onServerToggle,
    required this.onToolToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = profile.activeMcpName.contains(client.id);

    return Column(
      children: [
        SwitchListTile(
          title: Text(client.name),
          subtitle: Text(client.url ?? 'Stdio/Local Server'),
          secondary: const Icon(Icons.dns_outlined),
          value: isActive,
          onChanged: (val) => onServerToggle(client.id, val),
        ),
        if (isActive)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: toolsList.tools.map((tool) {
                final activeServer = profile.activeMcp.firstWhere(
                  (s) => s.id == client.id,
                );
                final isToolEnabled = activeServer.activeToolNames.contains(
                  tool['name'],
                );

                return CheckboxListTile(
                  title: Text(
                    tool['name'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: tool['description'] != null
                      ? Text(
                          tool['description'],
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
                      onToolToggle(client.id, tool['name'], val ?? false),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
