import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:multigateway/app/config/theme.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/services/message_helper.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_message_widgets/message_attachments_bar.dart';
/// Widget hiển thị tin nhắn của người dùng
class UserMessageCard extends StatelessWidget {
  final StoredMessage message;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(List<String>)? onOpenAttachments;
  final Function(int)? onSwitchVersion;

  const UserMessageCard({
    super.key,
    required this.message,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onOpenAttachments,
    this.onSwitchVersion,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).extension<SecondarySurface>();
    final bg =
        secondary?.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final borderSide =
        secondary?.borderSide ??
        BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(80),
          width: 1,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: GestureDetector(
            onLongPressStart: (details) =>
                _showContextMenu(context, details.globalPosition),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 560),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderSide.color,
                  width: borderSide.width,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.files.isNotEmpty)
                    MessageAttachmentsBar(
                      attachments: message.files,
                      onOpenAttachments: onOpenAttachments,
                    ),
                  if ((message.content ?? '').trim().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: message.files.isNotEmpty ? 8 : 0,
                      ),
                      child: MarkdownBody(
                        data: message.content ?? '',
                        selectable: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 15.5, height: 1.5),
                              listBullet: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPos) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // Build menu items với icons
    final List<PopupMenuEntry<String>> menuItems = [
      PopupMenuItem(
        value: 'copy',
        child: Row(
          children: [
            const Icon(Icons.copy, size: 18),
            const SizedBox(width: 12),
            Text(tl('Copy')),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Icons.edit, size: 18),
            const SizedBox(width: 12),
            Text(tl('Edit')),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete, size: 18),
            const SizedBox(width: 12),
            Text(tl('Delete')),
          ],
        ),
      ),
    ];

    // Thêm version switcher nếu có nhiều version
    if (message.versions.length > 1) {
      menuItems.insert(0, const PopupMenuDivider());
      for (int i = message.versions.length - 1; i >= 0; i--) {
        final isSelected = i == message.currentVersionIndex;
        menuItems.insert(
          0,
          PopupMenuItem(
            value: 'version_$i',
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text('${tl('Version')} ${i + 1}'),
              ],
            ),
          ),
        );
      }
    }

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        overlay.size.width - globalPos.dx,
        overlay.size.height - globalPos.dy,
      ),
      items: menuItems,
    );

    if (selected == null) return;

    if (selected.startsWith('version_')) {
      final versionIndex = int.tryParse(selected.replaceFirst('version_', ''));
      if (versionIndex != null) {
        onSwitchVersion?.call(versionIndex);
      }
      return;
    }

    switch (selected) {
      case 'copy':
        onCopy?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
