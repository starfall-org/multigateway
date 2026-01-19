import 'package:flutter/material.dart';
import 'package:multigateway/core/mcp/models/mcp_info.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/resource_tile.dart';

/// Widget hiển thị MCP server dạng tile trong list view
class McpItemTile extends StatelessWidget {
  final McpInfo server;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const McpItemTile({
    super.key,
    required this.server,
    required this.subtitle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ResourceTile(
      key: ValueKey(server.id),
      title: server.name,
      subtitle: subtitle,
      leadingIcon: buildIcon(server.name),
      onTap: onTap,
      onDelete: onDelete,
      onEdit: onEdit,
    );
  }
}
