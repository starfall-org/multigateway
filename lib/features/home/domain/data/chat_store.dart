import 'dart:async';

import 'package:multigateway/core/chat/storage/conversation_storage.dart';

typedef ChatRepository = ConversationStorage;

Future<ChatRepository> initChatRepository() => ConversationStorage.init();
