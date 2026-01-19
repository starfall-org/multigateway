import 'dart:async';

import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/core/storage/base.dart';

class ConversationStorage extends HiveBaseStorage<Conversation> {
  static const String _prefix = 'conversation';

  static ConversationStorage? _instance;
  static Future<ConversationStorage>? _instanceFuture;

  ConversationStorage();

  static Future<ConversationStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<ConversationStorage> init() async {
    final instance = ConversationStorage();
    await instance.ensureBoxReady();
    return instance;
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
    // Loại bỏ các session trống để không trả về/hiển thị
    sessions.removeWhere((s) => s.messages.isEmpty);
    // Sort by updated at descending
    sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sessions;
  }
}
