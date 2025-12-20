part of 'chat_viewmodel.dart';

extension ChatViewModelOperations on ChatViewModel {
  String getTranscript() {
    if (currentSession == null) return '';
    return currentSession!.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'role.you'.tr(context: scaffoldKey.currentContext!)
              : (m.role == ChatRole.model
                    ? (selectedProfile?.name ?? 'AI')
                    : 'role.system'.tr(context: scaffoldKey.currentContext!));
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> clearChat() async {
    if (currentSession == null) return;
    currentSession = currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notify();
    await chatRepository.saveConversation(currentSession!);
  }

  Future<void> speakLastModelMessage() async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;
    final lastModel = currentSession!.messages.lastWhere(
      (m) => m.role == ChatRole.model,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastModel.content.isEmpty) return;
    await ttsService.speak(lastModel.content);
  }
}
