import 'dart:async';
import '../models/chat/conversation.dart';
import '../models/chat/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'shared_prefs_base_repository.dart';

class ChatRepository extends SharedPreferencesBaseRepository<Conversation> {
  static const String _prefix = 'conv';

  ChatRepository(super.prefs);

  static Future<ChatRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ChatRepository(prefs);
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(Conversation item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(Conversation item) {
    return {
      'id': item.id,
      'title': item.title,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'messages': item.messages.map((m) => m.toJson()).toList(),
      'tokenCount': item.tokenCount,
      'isAgentConversation': item.isAgentConversation,
      'providerName': item.providerName,
      'modelName': item.modelName,
      'enabledToolNames': item.enabledToolNames,
    };
  }

  @override
  Conversation deserializeFromFields(String id, Map<String, dynamic> fields) {
    return Conversation(
      id: fields['id'] as String,
      title: fields['title'] as String,
      createdAt: DateTime.parse(fields['createdAt'] as String),
      updatedAt: DateTime.parse(fields['updatedAt'] as String),
      messages:
          (fields['messages'] as List?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tokenCount: fields['tokenCount'] as int?,
      isAgentConversation: fields['isAgentConversation'] as bool? ?? false,
      providerName: fields['providerName'] as String?,
      modelName: fields['modelName'] as String?,
      enabledToolNames: (fields['enabledToolNames'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  @override
  List<Conversation> getItems() {
    final sessions = super.getItems();
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }

  List<Conversation> getConversations() => getItems();

  /// Reactive stream of conversations; emits immediately and on each change.
  Stream<List<Conversation>> get conversationsStream => itemsStream;

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
