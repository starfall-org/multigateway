import 'dart:async';

import 'package:dartantic_ai/dartantic_ai.dart' as dai;
import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/services/chat_service.dart';
import 'package:multigateway/features/home/services/message_helper.dart';

/// Service xử lý stream response cho tin nhắn
class MessageStreamService {
  /// Xử lý stream response từ AI model
  static Future<void> handleStreamResponse({
    required String userText,
    required List<StoredMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
    String? existingMessageId,
    List<dai.Part>? files,
    BuildContext? context,
    void Function(
      StreamSubscription<dai.ChatResult> subscription,
      Completer<void> completer,
    )? onListen,
  }) async {
    final stream = ChatService.generateStream(
      userText: userText,
      history: _mapHistoryToProvider(history),
      files: files,
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
        dai.ChatMessage.model(''),
      );
    } else {
      final placeholder = MessageHelper.createModelMessagePlaceholder();
      modelId = placeholder.id;
      session = MessageHelper.addMessageToSession(session, placeholder);
    }

    onSessionUpdate(session);
    onScrollToBottom();


    try {
      // Force the very first chunk to render immediately
      var lastEmittedContent = '';
      var acc = '';
      String? reasoning;

      final completer = Completer<void>();
      late final StreamSubscription<dai.ChatResult> sub;

      sub = stream.listen(
        (chunk) {
          // Streaming chunks return content via output property, not messages
          // Messages are typically only populated at the end or contain tool calls
          final output = chunk.output.toString();
          if (output.isNotEmpty) {
            acc += output;
          }

          if (chunk.thinking != null && chunk.thinking!.isNotEmpty) {
            reasoning = chunk.thinking;
          }

          if (acc != lastEmittedContent) {
            session = MessageHelper.updateMessageActiveContent(
              session,
              modelId,
              acc,
              reasoningContent: reasoning,
            );
            onSessionUpdate(session);
            lastEmittedContent = acc;
          }
        },
        onError: (e, stackTrace) async {
          if (!completer.isCompleted) {
            completer.completeError(e, stackTrace);
          }
        },
        onDone: () {
          // Final update
          final currentMessage = session.messages.firstWhere(
            (m) => m.id == modelId,
            orElse: () => throw StateError('Message not found'),
          );
          if (currentMessage.content != acc) {
            session = MessageHelper.updateMessageActiveContent(
              session,
              modelId,
              acc,
              reasoningContent: reasoning,
            );
            onSessionUpdate(session);
          }

          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        cancelOnError: true,
      );

      onListen?.call(sub, completer);
      await completer.future;
    } catch (e, stackTrace) {
      await MessageHelper.handleError(
        e,
        stackTrace,
        context: context?.mounted == true ? context : null,
        debugMessage: 'Error in handleStreamResponse',
      );
      rethrow;
    } finally {
      // Không tự động cuộn khi kết thúc - để người dùng tự quyết định
    }
  }

  /// Xử lý non-stream response từ AI model
  static Future<void> handleNonStreamResponse({
    required String userText,
    required List<StoredMessage> history,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    List<String>? allowedToolNames,
    String? existingMessageId,
    List<dai.Part>? files,
    BuildContext? context,
  }) async {
    try {
      final reply = await ChatService.generateReply(
        userText: userText,
        history: _mapHistoryToProvider(history),
        files: files,
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      // Collect model message text from ChatResult.messages
      final modelMessage = reply.messages.firstWhere(
        (msg) => msg.role == dai.ChatMessageRole.model,
        orElse: () => dai.ChatMessage.model(''),
      );
      final reasoning = reply.thinking;
      final content = modelMessage.text;

      var session = currentSession;
      if (existingMessageId != null) {
        session = MessageHelper.addVersionToMessageInSession(
          session,
          existingMessageId,
          modelMessage,
          reasoningContent: reasoning,
        );
      } else {
        final modelMessageStored = MessageHelper.createModelChatMessage(
          modelMessage,
          reasoningContent: reasoning,
        );
        session = MessageHelper.addMessageToSession(
          session,
          modelMessageStored,
        );
        if (reasoning != null && reasoning.isNotEmpty) {
          // store reasoning on active version
          session = MessageHelper.updateMessageActiveContent(
            session,
            modelMessageStored.id,
            content,
            reasoningContent: reasoning,
          );
        }
      }

      onSessionUpdate(session);
      onScrollToBottom();

    } catch (e, stackTrace) {
      await MessageHelper.handleError(
        e,
        stackTrace,
        context: context?.mounted == true ? context : null,
        debugMessage: 'Error in handleNonStreamResponse',
      );
      rethrow;
    } finally {
      // Không tự động cuộn - để người dùng tự quyết định
    }
  }

  static List<dai.ChatMessage> _mapHistoryToProvider(
    List<StoredMessage> history,
  ) {
    return history
        .map(
          (m) => dai.ChatMessage(
            role: switch ((m['role'] as String?) ?? '') {
              'model' => dai.ChatMessageRole.model,
              'system' => dai.ChatMessageRole.system,
              _ => dai.ChatMessageRole.user,
            },
            parts: [dai.TextPart((m.content ?? ''))],
          ),
        )
        .toList();
  }
}
