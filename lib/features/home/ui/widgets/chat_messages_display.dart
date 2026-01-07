import 'package:flutter/material.dart';
import 'package:multigateway/features/home/domain/domain.dart';
import 'package:multigateway/features/home/ui/widgets/chat_message_widgets/assistant_message_card.dart';
import 'package:multigateway/features/home/ui/widgets/chat_message_widgets/user_message_card.dart';

/// Widget hiển thị danh sách tin nhắn chat
class ChatMessagesDisplay extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  // Callbacks để liên kết với Controller/Screen
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
            ? UserMessageCard(
                message: message,
                onCopy: onCopy != null ? () => onCopy!(message) : null,
                onEdit: onEdit != null ? () => onEdit!(message) : null,
                onDelete: onDelete != null ? () => onDelete!(message) : null,
                onOpenAttachments: onOpenAttachmentsSidebar,
                onSwitchVersion: onSwitchVersion != null
                    ? (idx) => onSwitchVersion!(message, idx)
                    : null,
              )
            : AssistantMessageCard(
                message: message,
                onCopy: onCopy != null ? () => onCopy!(message) : null,
                onEdit: onEdit != null ? () => onEdit!(message) : null,
                onDelete: onDelete != null ? () => onDelete!(message) : null,
                onRegenerate: onRegenerate,
                onRead: onRead != null ? () => onRead!(message) : null,
                onSwitchVersion: onSwitchVersion != null
                    ? (idx) => onSwitchVersion!(message, idx)
                    : null,
              );
      },
    );
  }
}
