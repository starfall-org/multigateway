import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:uuid/uuid.dart';

/// Controller responsible for managing chat sessions/conversations
class SessionController extends ChangeNotifier {
  final ConversationStorage conversationRepository;

  Conversation? currentSession;
  bool isLoading = true;
  bool continueLastConversation = true;

  SessionController({
    required this.conversationRepository,
    this.continueLastConversation = true,
  });

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

    if (continueLastConversation && nonEmptySessions.isNotEmpty) {
      currentSession = nonEmptySessions.first;
      isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
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
    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    isLoading = true;
    notifyListeners();

    final sessions = conversationRepository.getItems();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveCurrentSession() async {
    if (currentSession != null && currentSession!.messages.isNotEmpty) {
      await conversationRepository.saveItem(currentSession!);
    }
  }

  Future<void> clearChat() async {
    if (currentSession == null) return;
    currentSession = currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await conversationRepository.saveItem(currentSession!);
  }

  void updateSession(Conversation session) {
    currentSession = session;
    notifyListeners();
  }

  void clearLoadingState() {
    isLoading = false;
    notifyListeners();
  }

  String getTranscript({String? profileName}) {
    if (currentSession == null) return '';
    return currentSession!.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'You'
              : (m.role == ChatRole.model ? (profileName ?? 'AI') : 'System');
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }
}
