import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
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
        return _buildMessageBubble(context, message, isUser);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isUser) {
    final bubbleColor = isUser ? Colors.blue : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nội dung tin nhắn
            if (isUser)
              Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              )
            else
              // Model: hỗ trợ Markdown để trình bày tốt hơn
              MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: const TextStyle(fontSize: 15, color: Colors.black87),
                  code: const TextStyle(fontSize: 13),
                ),
              ),

            // Hình/đính kèm (nếu có)
            if (message.attachments.isNotEmpty) const SizedBox(height: 8),
            if (message.attachments.isNotEmpty)
              _buildAttachments(message.attachments, isUser),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(List<String> attachments, bool isUser) {
    final imagePaths = attachments.where(_isImagePath).toList();
    final otherPaths = attachments.where((p) => !_isImagePath(p)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imagePaths.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: imagePaths.map((path) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 180,
                  height: 120,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackAttachmentTile(path, isUser),
                  ),
                ),
              );
            }).toList(),
          ),
        if (otherPaths.isNotEmpty) const SizedBox(height: 6),
        if (otherPaths.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: -8,
            children: otherPaths.map((p) => _attachmentChip(p, isUser)).toList(),
          ),
      ],
    );
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

  Widget _attachmentChip(String path, bool isUser) {
    final name = path.split('/').last;
    return Chip(
      avatar: Icon(
        Icons.attachment,
        size: 16,
        color: isUser ? Colors.white : Colors.black54,
      ),
      label: Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
      ),
      backgroundColor: isUser ? Colors.blue.withOpacity(0.2) : Colors.grey[300],
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _fallbackAttachmentTile(String path, bool isUser) {
    final name = path.split('/').last;
    return Container(
      color: isUser ? Colors.white.withOpacity(0.15) : Colors.black12,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.image_not_supported, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
