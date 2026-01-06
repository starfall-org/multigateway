import 'dart:async';

import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/core/storage/base.dart';

class ConversationStorage extends HiveBaseStorage<Conversation> {
  static const String _prefix = 'conversation';

  ConversationStorage();

  static Future<ConversationStorage> init() async {
    return ConversationStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(Conversation item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(Conversation item) {
    return item.toJson();
  }

  @override
  Conversation deserializeFromFields(String id, Map<String, dynamic> fields) {
    return Conversation.fromJson(fields);
  }

  @override
  List<Conversation> getItems() {
    final sessions = super.getItems();
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }
}
