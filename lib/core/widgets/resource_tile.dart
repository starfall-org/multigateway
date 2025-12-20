import 'package:flutter/material.dart';
import 'item_card.dart';

class ResourceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leadingIcon;
  final Color? leadingColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Widget? trailing;

  const ResourceTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.subtitle,
    this.leadingColor,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCard(
      layout: ItemCardLayout.list,
      elevation: 0,
      title: title,
      subtitle: subtitle,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (leadingColor ?? Theme.of(context).primaryColor).withValues(
            alpha: 0.1,
          ),
          shape: BoxShape.circle,
        ),
        child: leadingIcon,
      ),
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
      trailing: trailing,
      // Note: ItemCard uses padding for contentPadding in list mode
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
