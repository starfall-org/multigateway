import 'package:flutter/material.dart';
import 'package:multigateway/core/mcp/models/mcp_info.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

/// Widget hiển thị MCP server dạng card trong grid view
class McpItemCard extends StatelessWidget {
  final McpInfo server;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const McpItemCard({
    super.key,
    required this.server,
    required this.subtitle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      icon: buildIcon(server.name),
      title: server.name,
      subtitle: subtitle,
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
