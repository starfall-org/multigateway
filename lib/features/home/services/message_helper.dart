import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/shared/widgets/error_debug_dialog.dart';
import 'package:uuid/uuid.dart';

/// Helper class for common message operations to reduce code duplication
class MessageHelper {
  /// Creates a new user message with the given content and attachments
  static ChatMessage createUserMessage(String text, List<String> attachments) {
    return ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      files: attachments,
    );
  }

  /// Creates a new model message placeholder
  static ChatMessage createModelMessagePlaceholder() {
    return ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: '',
      timestamp: DateTime.now(),
    );
  }

  /// Creates a new model message with content
  static ChatMessage createModelMessage(String content) {
    return ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// Updates a session with new messages and current timestamp
  static Conversation updateSessionWithMessages(
    Conversation session,
    List<ChatMessage> messages,
  ) {
    return session.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a message to the session and returns the updated session
  static Conversation addMessageToSession(
    Conversation session,
    ChatMessage message,
  ) {
    return session.copyWith(
      messages: [...session.messages, message],
      updatedAt: DateTime.now(),
    );
  }

  /// Updates a specific message in the session by ID
  static Conversation updateMessageInSession(
    Conversation session,
    String messageId,
    ChatMessage updatedMessage,
  ) {
    final msgs = List<ChatMessage>.from(session.messages);
    final idx = msgs.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      msgs[idx] = updatedMessage;
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }

  /// Adds a new version to an existing message in the session
  static Conversation addVersionToMessageInSession(
    Conversation session,
    String messageId,
    String content, {
    List<String>? files,
    String? reasoningContent,
    Map<String, dynamic>? toolCall,
  }) {
    final msgs = List<ChatMessage>.from(session.messages);
    final idx = msgs.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final existing = msgs[idx];
      final updated = existing.addVersion(
        MessageContents(
          content: content,
          timestamp: DateTime.now(),
          files: files ?? [],
          reasoningContent: reasoningContent,
          toolCall: toolCall ?? {},
        ),
      );
      msgs[idx] = updated;
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }

  /// Updates the active content of a message in the session
  static Conversation updateMessageActiveContent(
    Conversation session,
    String messageId,
    String content,
  ) {
    final msgs = List<ChatMessage>.from(session.messages);
    final idx = msgs.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      final old = msgs[idx];
      msgs[idx] = old.updateActiveContent(content);
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }

  /// Removes a message from the session by ID
  static Conversation removeMessageFromSession(
    Conversation session,
    String messageId,
  ) {
    final msgs = List<ChatMessage>.from(session.messages)
      ..removeWhere((m) => m.id == messageId);
    return session.copyWith(messages: msgs, updatedAt: DateTime.now());
  }

  /// Standard error handling with debug dialog support
  static Future<void> handleError(
    dynamic error,
    StackTrace stackTrace, {
    BuildContext? context,
    String? debugMessage,
  }) async {
    final message = debugMessage ?? 'Error occurred';
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());

    if (context != null && context.mounted) {
      final prefs = await PreferencesStorage.instance;
      if (context.mounted && prefs.currentPreferences.debugMode) {
        ErrorDebugDialog.show(context, error: error, stackTrace: stackTrace);
      }
    }
  }

  /// Finds the last user message index in a conversation
  static int findLastUserMessageIndex(List<ChatMessage> messages) {
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == ChatRole.user) {
        return i;
      }
    }
    return -1;
  }

  /// Gets history up to a specific message index
  static List<ChatMessage> getHistoryUpTo(
    List<ChatMessage> messages,
    int index,
  ) {
    return messages.take(index).toList();
  }

  /// Switches message version in session
  static Conversation switchMessageVersionInSession(
    Conversation session,
    String messageId,
    int versionIndex,
  ) {
    final msgs = List<ChatMessage>.from(session.messages);
    final idx = msgs.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      msgs[idx] = msgs[idx].switchVersion(versionIndex);
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }
}