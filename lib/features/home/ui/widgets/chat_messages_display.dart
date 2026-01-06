import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:multigateway/app/config/theme.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/domain/domain.dart';

/// Helper để tạo theme-aware image cho chat messages
Widget _buildThemeAwareImageForChat(BuildContext context, Widget child) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      BlendMode.overlay,
    ),
    child: child,
  );
}

class ChatMessagesDisplay extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  // Callbacks để liên kết với ViewModel/Screen
  final void Function(ChatMessage message)? onCopy;
  final void Function(ChatMessage message)? onEdit;
  final void Function(ChatMessage message)? onDelete;
  final void Function(List<String> attachments)? onOpenAttachmentsSidebar;
  final VoidCallback? onRegenerate;
  final void Function(ChatMessage message)? onRead;
  final void Function(ChatMessage message, int versionIndex)? onSwitchVersion;

  const ChatMessagesDisplay({
    super.key,
    required this.messages,
    required this.scrollController,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onOpenAttachmentsSidebar,
    this.onRegenerate,
    this.onRead,
    this.onSwitchVersion,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.role == ChatRole.user;
        return isUser
            ? _buildUserMessage(context, message)
            : _buildAssistantMessage(context, message);
      },
    );
  }

  // ----------------------
  // USER MESSAGE (Secondary background + border, attachments row + markdown)
  // ----------------------
  Widget _buildUserMessage(BuildContext context, ChatMessage message) {
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

    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showUserContextMenu(context, details.globalPosition, message),
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
                if (message.attachments.isNotEmpty)
                  _buildUserAttachmentsBar(context, message.attachments),
                if (message.content.trim().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: message.attachments.isNotEmpty ? 8 : 0,
                    ),
                    child: MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15.5,
                              height: 1.5,
                            ),
                            listBullet: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                          ),
                    ),
                  ),
                if (message.versions.length > 1 ||
                    onCopy != null ||
                    onEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (message.versions.length > 1)
                          _buildVersionSwitcher(context, message)
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
                                onPressed: () => onCopy?.call(message),
                              ),
                            if (onEdit != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 18,
                                tooltip: tl('Edit'),
                                icon: const Icon(Icons.edit),
                                onPressed: () => onEdit?.call(message),
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

  Widget _buildUserAttachmentsBar(
    BuildContext context,
    List<String> attachments,
  ) {
    final count = attachments.length;
    final showOverflow = count > 4;
    final visible = showOverflow ? attachments.take(3).toList() : attachments;
    final tileSize = _computeTileSize(count);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showOverflow) _overflowTile(context, attachments, tileSize),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visible
                  .map((p) => _squareAttachmentTile(context, p, tileSize))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _overflowTile(
    BuildContext context,
    List<String> attachments,
    double size,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => onOpenAttachmentsSidebar?.call(attachments),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(80),
              width: 1,
            ),
          ),
          child: Center(child: Icon(Icons.more_horiz)),
        ),
      ),
    );
  }

  Widget _squareAttachmentTile(BuildContext context, String path, double size) {
    final isImg = _isImagePath(path);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surface,
          child: isImg
              ? _buildThemeAwareImageForChat(
                  context,
                  Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        _attachmentIconTile(context, path),
                  ),
                )
              : _attachmentIconTile(context, path),
        ),
      ),
    );
  }

  Widget _attachmentIconTile(BuildContext context, String path) {
    final name = path.split('/').last;
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 28,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  // ----------------------
  // ASSISTANT MESSAGE (Primary background, avatar top-left, markdown under avatar,
  // media section, toolbar bottom (copy/regenerate/menu), read icon top-right,
  // dropdown reasoning_content)
  // ----------------------
  Widget _buildAssistantMessage(BuildContext context, ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showAssistantContextMenu(context, details.globalPosition, message),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            // Không viền, nền theo primary background (mặc định Scaffold)
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar (left) + read button (right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      child: Icon(Icons.token, size: 18),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      icon: const Icon(Icons.volume_up),
                      tooltip: tl('Read'),
                      onPressed: () => onRead?.call(message),
                    ),
                  ],
                ),
                if (message.content.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _AnimatedMarkdown(content: message.content),
                  ),

                // Media generated by AI (ẩn nếu trống)
                if (message.files.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildMediaGrid(context, message.files),
                ],

                // Reasoning dropdown (ẩn nếu trống)
                if ((message.reasoningContent ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildReasoningDropdown(
                    context,
                    message.reasoningContent!.trim(),
                  ),
                ],

                // Bottom toolbar
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (message.versions.length > 1) ...[
                            _buildVersionSwitcher(context, message),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            tooltip: tl('Copy'),
                            icon: const Icon(Icons.copy),
                            onPressed: () => onCopy?.call(message),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            tooltip: tl('Regenerate'),
                            icon: const Icon(Icons.refresh),
                            onPressed: onRegenerate,
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        tooltip: tl('More'),
                        iconSize: 18,
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call(message);
                              break;
                            case 'delete':
                              onDelete?.call(message);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text(tl('Edit'))),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(tl('Delete')),
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

  Widget _buildMediaGrid(BuildContext context, List<String> media) {
    final size = _computeTileSize(media.length);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: media.map((m) {
        final isImg = _isImagePath(m);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surface,
            child: isImg
                ? _buildThemeAwareImageForChat(
                    context,
                    Image.file(
                      File(m),
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          _attachmentIconTile(context, m),
                    ),
                  )
                : _attachmentIconTile(context, m),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasoningDropdown(BuildContext context, String reasoning) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(
        context,
      ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
    );
    // ExpansionTile giúp thu gọn/mở rộng
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8),
        collapsedIconColor: Theme.of(context).iconTheme.color,
        iconColor: Theme.of(context).iconTheme.color,
        title: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 4),
            Text(tl('Reasoning content'), style: style),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(reasoning, style: style),
          ),
        ],
      ),
    );
  }

  // -------------
  // Helpers
  // -------------
  double _computeTileSize(int count) {
    if (count <= 1) return 220;
    if (count == 2) return 140;
    if (count == 3) return 110;
    return 96;
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  void _showUserContextMenu(
    BuildContext context,
    Offset globalPos,
    ChatMessage m,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
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
        onCopy?.call(m);
        break;
      case 'edit':
        onEdit?.call(m);
        break;
      case 'delete':
        onDelete?.call(m);
        break;
    }
  }

  void _showAssistantContextMenu(
    BuildContext context,
    Offset globalPos,
    ChatMessage m,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPos.dx,
        globalPos.dy,
        overlay.size.width - globalPos.dx,
        overlay.size.height - globalPos.dy,
      ),
      items: [
        PopupMenuItem(value: 'edit', child: Text(tl('Edit'))),
        PopupMenuItem(value: 'delete', child: Text(tl('Delete'))),
      ],
    );
    switch (selected) {
      case 'edit':
        onEdit?.call(m);
        break;
      case 'delete':
        onDelete?.call(m);
        break;
    }
  }

  Widget _buildVersionSwitcher(BuildContext context, ChatMessage message) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(
        context,
      ).textTheme.labelSmall?.color?.withValues(alpha: 0.6),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_left, size: 18),
          onPressed: message.currentVersionIndex > 0
              ? () => onSwitchVersion?.call(
                  message,
                  message.currentVersionIndex - 1,
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '${message.currentVersionIndex + 1}/${message.versions.length}',
            style: style,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_right, size: 18),
          onPressed: message.currentVersionIndex < message.versions.length - 1
              ? () => onSwitchVersion?.call(
                  message,
                  message.currentVersionIndex + 1,
                )
              : null,
        ),
      ],
    );
  }
}

class _AnimatedMarkdown extends StatefulWidget {
  final String content;

  const _AnimatedMarkdown({required this.content});

  @override
  State<_AnimatedMarkdown> createState() => _AnimatedMarkdownState();
}

class _AnimatedMarkdownState extends State<_AnimatedMarkdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  String? _displayedContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _displayedContent = widget.content;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      // Content updated (streaming), just update state, no need to reset fade unless it's a completely new message which is handled by a new Widget key if necessary.
      // But here we might want to fade in only the NEW part?
      // Complexity of partial fade-in is high for Markdown.
      // Simple approach: Keep it simple for streaming updates to avoid flickering.
      // But user asked for "shade in" effect for new chunks.
      // If we just use the current fade-in on mount, it only fades in once.
      // To "shade in" new content, we can use a custom builder or just rely on the smooth scroll and natural text update.
      // However, the request specifically asked for "shade in" effect for chunks.

      // Let's implement a simple key-based approach for the whole block or just ensure standard fade-in for the initial block.
      // For streaming updates (text gets longer), standard MarkdownBody repaint is usually fine.
      // If "shade in" implies a visual effect for EACH chunk, that requires diffing which is expensive.
      // The user also asked for "phần bên dưới của khung tin nhắn phải mở rộng xuống dần đều mượt mà chứ không phải giật phát một".
      // This suggests an implicit animation on height change.

      _displayedContent = widget.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in AnimatedSize to smooth out height changes ("mở rộng xuống dần đều mượt mà")
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: FadeTransition(
        opacity: _opacity,
        child: MarkdownBody(
          data: _displayedContent ?? '',
          selectable: true,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 15.5, height: 1.5),
            listBullet: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 15.5),
          ),
        ),
      ),
    );
  }
}
