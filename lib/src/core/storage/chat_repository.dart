import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/chat/domain/chat_models.dart';

class ChatRepository {
  static const String _storageKey = 'chat_sessions';
  final SharedPreferences _prefs;

  ChatRepository(this._prefs);

  static Future<ChatRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatRepository(prefs);
  }

  List<ChatSession> getSessions() {
    final List<String>? sessionsJson = _prefs.getStringList(_storageKey);
    if (sessionsJson == null || sessionsJson.isEmpty) {
      return [];
    }
    final sessions = sessionsJson
        .map((str) => ChatSession.fromJsonString(str))
        .toList();
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  Future<ChatSession> createSession() async {
    final session = ChatSession(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    await saveSession(session);
    return session;
  }

  Future<void> saveSession(ChatSession session) async {
    final sessions = getSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);

    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    await _saveSessions(sessions);
  }

  Future<void> deleteSession(String id) async {
    final sessions = getSessions();
    sessions.removeWhere((s) => s.id == id);
    await _saveSessions(sessions);
  }

  Future<void> _saveSessions(List<ChatSession> sessions) async {
    final List<String> sessionsJson = sessions
        .map((s) => s.toJsonString())
        .toList();
    await _prefs.setStringList(_storageKey, sessionsJson);
  }
}
