import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/services/chat_service.dart';
import 'package:multigateway/features/home/services/message_helper.dart';

/// Service xử lý stream response cho tin nhắn
class MessageStreamService {
  /// Xử lý stream response từ AI model
  static Future<void> handleStreamResponse({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
    String? existingMessageId,
    BuildContext? context,
  }) async {
    final stream = ChatService.generateStream(
      userText: userText,
      history: history,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    );

    final String modelId;
    var session = currentSession;

    if (existingMessageId != null) {
      modelId = existingMessageId;
      session = MessageHelper.addVersionToMessageInSession(
        session,
        modelId,
        '',
      );
    } else {
      final placeholder = MessageHelper.createModelMessagePlaceholder();
      modelId = placeholder.id;
      session = MessageHelper.addMessageToSession(session, placeholder);
    }

    onSessionUpdate(session);

    try {
      DateTime lastUpdate = DateTime.now();
      const throttleDuration = Duration(milliseconds: 100);
      var acc = '';

      await for (final chunk in stream) {
        if (chunk.isEmpty) continue;
        acc += chunk;

        final now = DateTime.now();
        if (now.difference(lastUpdate) < throttleDuration) {
          continue;
        }

        final wasAtBottom = isNearBottom();
        
        session = MessageHelper.updateMessageActiveContent(session, modelId, acc);
        onSessionUpdate(session);

        if (wasAtBottom) {
          onScrollToBottom();
        }
        lastUpdate = now;
      }

      // Final update
      final currentMessage = session.messages
          .firstWhere((m) => m.id == modelId, orElse: () => throw StateError('Message not found'));
      if (currentMessage.content != acc) {
        session = MessageHelper.updateMessageActiveContent(session, modelId, acc);
        onSessionUpdate(session);
      }
    } catch (e, stackTrace) {
      await MessageHelper.handleError(
        e,
        stackTrace,
        context: context,
        debugMessage: 'Error in handleStreamResponse',
      );
      rethrow;
    } finally {
      if (isNearBottom()) {
        onScrollToBottom();
      }
    }
  }

  /// Xử lý non-stream response từ AI model
  static Future<void> handleNonStreamResponse({
    required String userText,
    required List<ChatMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    List<String>? allowedToolNames,
    String? existingMessageId,
    BuildContext? context,
  }) async {
    try {
      final reply = await ChatService.generateReply(
        userText: userText,
        history: history,
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      var session = currentSession;
      if (existingMessageId != null) {
        session = MessageHelper.addVersionToMessageInSession(
          session,
          existingMessageId,
          reply,
        );
      } else {
        final modelMessage = MessageHelper.createModelMessage(reply);
        session = MessageHelper.addMessageToSession(session, modelMessage);
      }

      onSessionUpdate(session);
    } catch (e, stackTrace) {
      await MessageHelper.handleError(
        e,
        stackTrace,
        context: context?.mounted == true ? context : null,
        debugMessage: 'Error in handleNonStreamResponse',
      );
      rethrow;
    } finally {
      onScrollToBottom();
    }
  }
}