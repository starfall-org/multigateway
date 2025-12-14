import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/home/models/chat_models.dart';
import 'base_repository.dart';

class ChatRepository extends BaseRepository<ChatSession> {
  static const String _storageKey = 'chat_sessions';

  ChatRepository(super.prefs);

  static Future<ChatRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  ChatSession deserializeItem(String json) => ChatSession.fromJsonString(json);

  @override
  String serializeItem(ChatSession item) => item.toJsonString();

  @override
  String getItemId(ChatSession item) => item.id;

  @override
  List<ChatSession> getItems() {
    final sessions = super.getItems();
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  List<ChatSession> getSessions() => getItems();

  Future<ChatSession> createSession() async {
    final session = ChatSession(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    await saveItem(session);
    return session;
  }

  Future<void> saveSession(ChatSession session) => saveItem(session);

  Future<void> deleteSession(String id) => deleteItem(id);
}
