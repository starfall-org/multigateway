import 'package:flutter/material.dart';

import '../../core/translate.dart';

enum ItemCardLayout { grid, list }

/// Thẻ hiển thị tài nguyên dạng lưới (Grid) hoặc danh sách (List) theo Material 3.
/// Dùng chung cho providers/agents/tts/mcp.
class ItemCard extends StatelessWidget {
  final Widget icon;
  final Color? iconColor;
  final String title;
  final Widget? subtitleWidget;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final ItemCardLayout layout;

  const ItemCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.leading,
    this.trailing,
    this.iconColor,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.elevation = 1,
    this.layout = ItemCardLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = iconColor ?? theme.colorScheme.primary;

    Widget buildSubtitle() {
      if (subtitleWidget != null) return subtitleWidget!;
      if (subtitle != null) {
        return Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
      return const SizedBox.shrink();
    }

    Widget cardBody;

    if (layout == ItemCardLayout.grid) {
      Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null || subtitleWidget != null) ...[
            const SizedBox(height: 4),
            buildSubtitle(),
          ],
        ],
      );

      // Nếu có trailing widget hoặc menu hành động
      if (leading != null ||
          trailing != null ||
          onView != null ||
          onEdit != null ||
          onDelete != null) {
        content = Stack(
          children: [
            if (leading != null) Positioned(top: 0, left: 0, child: leading!),
            Positioned.fill(child: content),
            Positioned(
              top: 0,
              right: 0,
              child:
                  trailing ??
                  _ActionMenu(
                    onView: onView,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
            ),
          ],
        );
      }
      cardBody = Padding(padding: padding, child: content);
    } else {
      // List layout
      cardBody = ListTile(
        contentPadding: padding,
        leading: icon,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: (subtitle != null || subtitleWidget != null)
            ? buildSubtitle()
            : null,
        trailing:
            trailing ??
            (onView != null || onEdit != null || onDelete != null
                ? _ActionMenu(
                    onView: onView,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  )
                : null),
        onTap: onTap,
      );
    }

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: layout == ItemCardLayout.grid
          ? InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onTap,
              child: cardBody,
            )
          : cardBody,
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionMenu({this.onView, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case _MenuAction.view:
            onView?.call();
            break;
          case _MenuAction.edit:
            onEdit?.call();
            break;
          case _MenuAction.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<_MenuAction>>[];
        if (onView != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.view,
              child: Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(tl('agents.view')),
                ],
              ),
            ),
          );
        }
        if (onEdit != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.edit,
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(tl('agents.edit')),
                ],
              ),
            ),
          );
        }
        if (onDelete != null) {
          items.add(
            PopupMenuItem(
              value: _MenuAction.delete,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(tl('agents.delete')),
                ],
              ),
            ),
          );
        }
        return items;
      },
    );
  }
}

enum _MenuAction { view, edit, delete }

/// Nút action trên AppBar để chuyển đổi giữa List và Grid theo Material Icons.
class ViewToggleAction extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;
  final String? listTooltip;
  final String? gridTooltip;

  const ViewToggleAction({
    super.key,
    required this.isGrid,
    required this.onChanged,
    this.listTooltip = 'List view',
    this.gridTooltip = 'Grid view',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isGrid ? listTooltip : gridTooltip,
      icon: Icon(isGrid ? Icons.view_list : Icons.grid_view_outlined),
      onPressed: () => onChanged(!isGrid),
    );
  }
}

/// Nút action trên AppBar để thêm tài nguyên theo Material Icons.
class AddAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const AddAction({super.key, required this.onPressed, this.tooltip = 'Add'});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}
