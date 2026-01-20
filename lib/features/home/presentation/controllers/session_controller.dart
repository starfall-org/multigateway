import 'dart:async';

import 'package:multigateway/core/chat/chat.dart';
import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';

/// Controller responsible for managing chat sessions/conversations
class SessionController {
  final ConversationStorage conversationRepository;

  final currentSession = signal<Conversation?>(null);
  final isLoading = signal<bool>(true);
  final continueLastConversation = signal<bool>(true);
  StreamSubscription<void>? _storageChangesSub;
  String? _persistedSessionId;

  SessionController({
    required this.conversationRepository,
    bool continueLastConversation = true,
  }) {
    this.continueLastConversation.value = continueLastConversation;
    _storageChangesSub = conversationRepository.changes.listen((_) {
      unawaited(_handleStorageChange());
    });
  }

  Future<void> initChat() async {
    // Chỉ đọc các session đã có tin nhắn
    final sessions = conversationRepository.getItems();
    final nonEmptySessions =
        sessions.where((s) => s.messages.isNotEmpty).toList();

    if (continueLastConversation.value && nonEmptySessions.isNotEmpty) {
      currentSession.value = nonEmptySessions.first;
      _persistedSessionId = nonEmptySessions.first.id;
      isLoading.value = false;
      return;
    }

    // Quy tắc: không giữ conversation rỗng -> nếu không còn chat nào có tin nhắn, tạo mới
    await createNewSession();
  }

  Future<void> createNewSession() async {
    final session = Conversation(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
      providerId: '',
      modelId: '',
      profileId: '',
    );
    currentSession.value = session;
    _persistedSessionId = null;
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
    _persistedSessionId = session.id;
    isLoading.value = false;
  }

  Future<void> saveCurrentSession() async {
    final session = currentSession.value;
    if (session == null) return;

    // Chỉ lưu khi có ít nhất 1 tin nhắn
    if (session.messages.isNotEmpty) {
      await conversationRepository.saveItem(session);
      _persistedSessionId = session.id;
    }
  }

  Future<void> clearChat() async {
    final session = currentSession.value;
    if (session == null) return;
    currentSession.value = session.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    // Không lưu phiên rỗng; giữ nguyên session mới trong bộ nhớ
  }

  void updateSession(Conversation session) {
    currentSession.value = session;
  }

  void clearLoadingState() {
    isLoading.value = false;
  }

  Future<void> ensureCurrentSessionAvailable() async {
    await _handleStorageChange();
  }

  String getTranscript({String? profileName}) {
    final session = currentSession.value;
    if (session == null) return '';
    return session.messages
        .map((m) {
          final role = m['role'] as String?;
          final content = m['content'] as String?;
          final who = role == 'user'
              ? 'You'
              : (role == 'model' || role == 'assistant'
                  ? (profileName ?? 'AI')
                  : 'System');
          return '$who: ${content ?? ''}';
        })
        .join('\n\n');
  }

  void dispose() {
    currentSession.dispose();
    isLoading.dispose();
    continueLastConversation.dispose();
    _storageChangesSub?.cancel();
    _storageChangesSub = null;
  }

  Future<void> _handleStorageChange() async {
    final session = currentSession.value;
    if (session == null) return;
    if (_persistedSessionId == null || _persistedSessionId != session.id) {
      return;
    }
    final stored = conversationRepository.getItem(session.id);
    if (stored == null) {
      await createNewSession();
    }
  }
}
