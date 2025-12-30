import 'package:flutter/material.dart';
import '../../domain/data/chat_store.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';

/// Controller responsible for managing chat sessions/conversations
class SessionController extends ChangeNotifier {
  final ChatRepository chatRepository;

  Conversation? currentSession;
  bool isLoading = true;

  SessionController({
    required this.chatRepository,
  });

  Future<void> initChat() async {
    final sessions = chatRepository.getConversations();

    if (sessions.isNotEmpty) {
      currentSession = sessions.first;
      isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
  }

  Future<void> createNewSession() async {
    final session = await chatRepository.createConversation();
    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    isLoading = true;
    notifyListeners();

    final sessions = chatRepository.getConversations();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveCurrentSession() async {
    if (currentSession != null) {
      await chatRepository.saveConversation(currentSession!);
    }
  }

  Future<void> clearChat() async {
    if (currentSession == null) return;
    currentSession = currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await chatRepository.saveConversation(currentSession!);
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
              : (m.role == ChatRole.model
                    ? (profileName ?? 'AI')
                    : 'System');
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }
}
