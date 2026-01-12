import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:multigateway/app/config/theme.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/features/home/ui/widgets/chat_message_widgets/message_attachments_bar.dart';
import 'package:multigateway/features/home/ui/widgets/chat_message_widgets/message_version_switcher.dart';

/// Widget hiển thị tin nhắn của người dùng
class UserMessageCard extends StatelessWidget {
  final ChatMessage message;
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
    final bg = secondary?.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final borderSide = secondary?.borderSide ??
        BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(80),
          width: 1,
        );

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showContextMenu(context, details.globalPosition),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
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
                      styleSheet: MarkdownStyleSheet.fromTheme(
                        Theme.of(context),
                      ).copyWith(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15.5,
                              height: 1.5,
                            ),
                        listBullet: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 15.5),
                      ),
                    ),
                  ),
                if (message.versions.length > 1 || onCopy != null || onEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (message.versions.length > 1)
                          MessageVersionSwitcher(
                            message: message,
                            onSwitchVersion: onSwitchVersion,
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            if (onCopy != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 18,
                                tooltip: tl('Copy'),
                                icon: const Icon(Icons.copy),
                                onPressed: onCopy,
                              ),
                            if (onEdit != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 18,
                                tooltip: tl('Edit'),
                                icon: const Icon(Icons.edit),
                                onPressed: onEdit,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPos) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        overlay.size.width - globalPos.dx,
        overlay.size.height - globalPos.dy,
      ),
      items: [
        PopupMenuItem(value: 'copy', child: Text(tl('Copy'))),
        PopupMenuItem(value: 'edit', child: Text(tl('Edit'))),
        PopupMenuItem(value: 'delete', child: Text(tl('Delete'))),
      ],
    );

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
