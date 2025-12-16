import 'package:ai_gateway/core/models/chat/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'base_repository.dart';

class ChatRepository extends BaseRepository<Conversation> {
  static const String _storageKey = 'conversations';

  ChatRepository(super.prefs);

  static Future<ChatRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  Conversation deserializeItem(String json) =>
      Conversation.fromJsonString(json);

  @override
  String serializeItem(Conversation item) => item.toJsonString();

  @override
  String getItemId(Conversation item) => item.id;

  @override
  List<Conversation> getItems() {
    final sessions = super.getItems();
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  List<Conversation> getConversations() => getItems();

  Future<Conversation> createConversation() async {
    final conversation = Conversation(
      id: const Uuid().v4(),
      title: 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );
    await saveItem(conversation);
    return conversation;
  }

  Future<void> saveConversation(Conversation conversation) =>
      saveItem(conversation);

  Future<void> deleteConversation(String id) => deleteItem(id);
}
