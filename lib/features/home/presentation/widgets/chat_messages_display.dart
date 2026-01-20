import 'package:flutter/material.dart';
import 'package:multigateway/features/home/presentation/widgets/assistant_message_card.dart';
import 'package:multigateway/features/home/presentation/widgets/user_message_card.dart';
import 'package:multigateway/features/home/services/message_helper.dart';

/// Widget hiển thị danh sách tin nhắn chat
class ChatMessagesDisplay extends StatefulWidget {
  final List<StoredMessage> messages;
  final ScrollController scrollController;
  final bool isGenerating;

  // Callbacks để liên kết với Controller/Screen
  final void Function(StoredMessage message)? onCopy;
  final void Function(StoredMessage message)? onEdit;
  final void Function(StoredMessage message)? onDelete;
  final void Function(List<String> attachments)? onOpenAttachmentsSidebar;
  final VoidCallback? onRegenerate;
  final void Function(StoredMessage message)? onRead;
  final void Function(StoredMessage message, int versionIndex)? onSwitchVersion;
  final String? modelId;

  const ChatMessagesDisplay({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isGenerating = false,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.onOpenAttachmentsSidebar,
    this.onRegenerate,
    this.onRead,
    this.onSwitchVersion,
    this.modelId,
  });

  @override
  State<ChatMessagesDisplay> createState() => _ChatMessagesDisplayState();
}

class _ChatMessagesDisplayState extends State<ChatMessagesDisplay> {
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final isAtBottom = _isNearBottom();
    if (_showScrollToBottom == isAtBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }
  }

  bool _isNearBottom() {
    if (!widget.scrollController.hasClients) return true;
    final position = widget.scrollController.position;
    return position.pixels >= position.maxScrollExtent - 100;
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            final message = widget.messages[index];
            final isUser = message.role == ChatRole.user;

            return isUser
                ? UserMessageCard(
                    message: message,
                    onCopy: widget.onCopy != null
                        ? () => widget.onCopy!(message)
                        : null,
                    onEdit: widget.onEdit != null
                        ? () => widget.onEdit!(message)
                        : null,
                    onDelete: widget.onDelete != null
                        ? () => widget.onDelete!(message)
                        : null,
                    onOpenAttachments: widget.onOpenAttachmentsSidebar,
                    onSwitchVersion: widget.onSwitchVersion != null
                        ? (idx) => widget.onSwitchVersion!(message, idx)
                        : null,
                  )
                : AssistantMessageCard(
                    message: message,
                    isStreaming:
                        widget.isGenerating &&
                        index == widget.messages.length - 1,
                    onCopy: widget.onCopy != null
                        ? () => widget.onCopy!(message)
                        : null,
                    onEdit: widget.onEdit != null
                        ? () => widget.onEdit!(message)
                        : null,
                    onDelete: widget.onDelete != null
                        ? () => widget.onDelete!(message)
                        : null,
                    onRegenerate: widget.onRegenerate,
                    onRead: widget.onRead != null
                        ? () => widget.onRead!(message)
                        : null,
                    onSwitchVersion: widget.onSwitchVersion != null
                        ? (idx) => widget.onSwitchVersion!(message, idx)
                        : null,
                    modelId: widget.modelId,
                  );
          },
        ),
        // Nút cuộn xuống cuối
        if (_showScrollToBottom)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
      ],
    );
  }
}
