part of 'chat_viewmodel.dart';

extension ChatViewModelEditActions on ChatViewModel {
  Future<void> copyMessage(BuildContext context, ChatMessage message) async {
    if (message.content.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (currentSession == null) return;
    final msgs = List<ChatMessage>.from(currentSession!.messages)
      ..removeWhere((m) => m.id == message.id);
    currentSession = currentSession!.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository.saveConversation(currentSession!);
  }

  Future<void> openEditMessageDialog(
    BuildContext context,
    ChatMessage message,
  ) async {
    final result = await EditMessageDialog.show(
      context,
      initialContent: message.content,
      initialAttachments: message.attachments,
    );
    if (result == null) return;
    if (!context.mounted) return;
    await applyMessageEdit(
      message,
      result.content,
      result.attachments,
      resend: result.resend,
      context: context,
    );
  }

  Future<void> applyMessageEdit(
    ChatMessage original,
    String newContent,
    List<String> newAttachments, {
    bool resend = false,
    BuildContext? context,
  }) async {
    if (currentSession == null) return;

    final msgs = List<ChatMessage>.from(currentSession!.messages);
    final idx = msgs.indexWhere((m) => m.id == original.id);
    if (idx == -1) return;

    final updated = ChatMessage(
      id: original.id,
      role: original.role,
      content: newContent,
      timestamp: original.timestamp,
      attachments: newAttachments,
      reasoningContent: original.reasoningContent,
      aiMedia: original.aiMedia,
    );
    msgs[idx] = updated;

    currentSession = currentSession!.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository.saveConversation(currentSession!);

    if (resend && context != null && context.mounted) {
      await regenerateLast(context);
    }
  }
}
