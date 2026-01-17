import 'package:multigateway/core/chat/chat.dart';
import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';

/// Controller responsible for managing chat sessions/conversations
class SessionController {
  final ConversationStorage conversationRepository;

  final currentSession = signal<Conversation?>(null);
  final isLoading = signal<bool>(true);
  final continueLastConversation = signal<bool>(true);

  SessionController({
    required this.conversationRepository,
    bool continueLastConversation = true,
  }) {
    this.continueLastConversation.value = continueLastConversation;
  }

  Future<void> initChat() async {
    final sessions = conversationRepository.getItems();

    // Xóa các conversation rỗng (không có messages)
    final emptySessions = sessions.where((s) => s.messages.isEmpty).toList();
    for (final emptySession in emptySessions) {
      await conversationRepository.deleteItem(emptySession.id);
    }

    // Lọc ra các conversation có nội dung
    final nonEmptySessions = sessions
        .where((s) => s.messages.isNotEmpty)
        .toList();

    if (continueLastConversation.value && nonEmptySessions.isNotEmpty) {
      currentSession.value = nonEmptySessions.first;
      isLoading.value = false;
    } else {
      await createNewSession();
    }
  }

  Future<void> createNewSession() async {
    final session = Conversation(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
      providerId: '',
      modelName: '',
      profileId: '',
    );
    await conversationRepository.saveItem(session);
    currentSession.value = session;
    isLoading.value = false;
  }

  Future<void> loadSession(String sessionId) async {
    isLoading.value = true;

    final sessions = conversationRepository.getItems();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    currentSession.value = session;
    isLoading.value = false;
  }

  Future<void> saveCurrentSession() async {
    final session = currentSession.value;
    if (session != null && session.messages.isNotEmpty) {
      await conversationRepository.saveItem(session);
    }
  }

  Future<void> clearChat() async {
    final session = currentSession.value;
    if (session == null) return;
    currentSession.value = session.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    await conversationRepository.saveItem(currentSession.value!);
  }

  void updateSession(Conversation session) {
    currentSession.value = session;
  }

  void clearLoadingState() {
    isLoading.value = false;
  }

  String getTranscript({String? profileName}) {
    final session = currentSession.value;
    if (session == null) return '';
    return session.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'You'
              : (m.role == ChatRole.model ? (profileName ?? 'AI') : 'System');
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }

  void dispose() {
    currentSession.dispose();
    isLoading.dispose();
    continueLastConversation.dispose();
  }
}
