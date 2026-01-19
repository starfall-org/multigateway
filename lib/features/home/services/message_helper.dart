import 'package:dartantic_ai/dartantic_ai.dart' as dai;
import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/shared/widgets/error_debug_dialog.dart';
import 'package:uuid/uuid.dart';

/// Helper class for common message operations to reduce code duplication
typedef StoredMessage = Map<String, dynamic>;

enum ChatRole { user, model, system }

extension StoredMessageX on StoredMessage {
  String get id => (this['id'] as String?) ?? '';
  ChatRole get role =>
      ChatRole.values.firstWhere(
        (e) => e.name == (this['role'] as String? ?? ''),
        orElse: () => ChatRole.user,
      );
  List<Map<String, dynamic>> get versions =>
      (this['versions'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
  int get activeVersionIndex =>
      (this['active_version_index'] as num?)?.toInt() ?? 0;
  int get currentVersionIndex => activeVersionIndex;
  Map<String, dynamic> get _activeVersion {
    final v = versions;
    final idx = activeVersionIndex.clamp(0, v.isNotEmpty ? v.length - 1 : 0);
    return v.isNotEmpty ? v[idx] : <String, dynamic>{};
  }

  dai.ChatMessage? get _activeChatMessage {
    final msgJson = _activeVersion['message'] as Map<String, dynamic>?;
    if (msgJson == null) return null;
    return dai.ChatMessage.fromJson(msgJson);
  }

  String? get content => _activeChatMessage?.text;
  List<String> get files =>
      (_activeVersion['files'] as List<dynamic>? ?? []).cast<String>();
  String? get reasoningContent =>
      _activeVersion['reasoning_content'] as String?;
  List<dai.ToolPart> get toolCalls =>
      _activeChatMessage?.toolCalls ?? const <dai.ToolPart>[];
}

class MessageHelper {
  static Map<String, dynamic> _buildVersion({
    required dai.ChatMessage message,
    List<String>? files,
    String? reasoningContent,
  }) {
    return {
      'message': message.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
      'files': files ?? <String>[],
      'reasoning_content': reasoningContent,
    };
  }

  /// Creates a new user message with the given content and attachments
  static StoredMessage createUserMessage(String text, List<String> attachments) {
    final base = dai.ChatMessage.user(
      text,
      metadata: {'files': attachments},
    );
    return {
      'id': const Uuid().v4(),
      'role': ChatRole.user.name,
      'versions': [
        _buildVersion(message: base, files: attachments),
      ],
      'active_version_index': 0,
    };
  }

  /// Creates a new model message placeholder
  static StoredMessage createModelMessagePlaceholder() {
    final base = dai.ChatMessage.model('');
    return {
      'id': const Uuid().v4(),
      'role': ChatRole.model.name,
      'versions': [
        _buildVersion(message: base),
      ],
      'active_version_index': 0,
    };
  }

  /// Creates a new model message with content
  static StoredMessage createModelMessage(String content) {
    final base = dai.ChatMessage.model(content);
    return {
      'id': const Uuid().v4(),
      'role': ChatRole.model.name,
      'versions': [
        _buildVersion(message: base),
      ],
      'active_version_index': 0,
    };
  }

  /// Creates a model message from an existing ChatMessage (preserves tool calls).
  static StoredMessage createModelChatMessage(
    dai.ChatMessage message, {
    String? reasoningContent,
  }) {
    return {
      'id': const Uuid().v4(),
      'role': ChatRole.model.name,
      'versions': [
        _buildVersion(
          message: message,
          reasoningContent: reasoningContent,
        ),
      ],
      'active_version_index': 0,
    };
  }

  /// Updates a session with new messages and current timestamp
  static Conversation updateSessionWithMessages(
    Conversation session,
    List<StoredMessage> messages,
  ) {
    return session.copyWith(
      messages: messages,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a message to the session and returns the updated session
  static Conversation addMessageToSession(
    Conversation session,
    StoredMessage message,
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
    StoredMessage updatedMessage,
  ) {
    final msgs =
        session.messages.map((m) => Map<String, dynamic>.from(m)).toList();
    final idx = msgs.indexWhere((m) => m['id'] == messageId);
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
    dai.ChatMessage message, {
    List<String>? files,
    String? reasoningContent,
  }) {
    final msgs =
        session.messages.map((m) => Map<String, dynamic>.from(m)).toList();
    final idx = msgs.indexWhere((m) => m['id'] == messageId);
    if (idx != -1) {
      final existing = msgs[idx];
      final versions =
          (existing['versions'] as List<dynamic>? ?? []).map((e) {
            return Map<String, dynamic>.from(e as Map);
          }).toList();
      versions.add(
        _buildVersion(
          message: message,
          files: files,
          reasoningContent: reasoningContent,
        ),
      );
      msgs[idx] = {
        ...existing,
        'versions': versions,
        'active_version_index': versions.length - 1,
      };
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }

  /// Updates the active content of a message in the session
  static Conversation updateMessageActiveContent(
    Conversation session,
    String messageId,
    String content, {
    String? reasoningContent,
  }) {
    final msgs =
        session.messages.map((m) => Map<String, dynamic>.from(m)).toList();
    final idx = msgs.indexWhere((m) => m['id'] == messageId);
    if (idx != -1) {
      final old = msgs[idx];
      final versions =
          (old['versions'] as List<dynamic>? ?? []).map((e) {
            return Map<String, dynamic>.from(e as Map);
          }).toList();
      final activeIndex =
          (old['active_version_index'] as num?)?.toInt() ?? 0;
      if (versions.isNotEmpty && activeIndex >= 0 && activeIndex < versions.length) {
        final originalMessage =
            dai.ChatMessage.fromJson(
              Map<String, dynamic>.from(
                versions[activeIndex]['message'] as Map<String, dynamic>? ?? {},
              ),
            );
        final nonTextParts =
            originalMessage.parts.where((p) => p is! dai.TextPart).toList();
        final updatedMessage = dai.ChatMessage(
          role: originalMessage.role,
          parts: [dai.TextPart(content), ...nonTextParts],
          metadata: originalMessage.metadata,
        );
        versions[activeIndex] = {
          ...versions[activeIndex],
          'message': updatedMessage.toJson(),
          if (reasoningContent != null)
            'reasoning_content': reasoningContent,
        };
        msgs[idx] = {
          ...old,
          'versions': versions,
        };
      }
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }

  /// Removes a message from the session by ID
  static Conversation removeMessageFromSession(
    Conversation session,
    String messageId,
  ) {
    final msgs = session.messages
        .map((m) => Map<String, dynamic>.from(m))
        .toList()
      ..removeWhere((m) => m['id'] == messageId);
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
  static int findLastUserMessageIndex(List<StoredMessage> messages) {
    for (int i = messages.length - 1; i >= 0; i--) {
      if ((messages[i]['role'] as String? ?? '') == ChatRole.user.name) {
        return i;
      }
    }
    return -1;
  }

  /// Gets history up to a specific message index
  static List<StoredMessage> getHistoryUpTo(
    List<StoredMessage> messages,
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
    final msgs =
        session.messages.map((m) => Map<String, dynamic>.from(m)).toList();
    final idx = msgs.indexWhere((m) => m['id'] == messageId);
    if (idx != -1) {
      final msg = msgs[idx];
      final versions =
          (msg['versions'] as List<dynamic>? ?? []).map((e) {
            return Map<String, dynamic>.from(e as Map);
          }).toList();
      if (versionIndex >= 0 && versionIndex < versions.length) {
        msgs[idx] = {
          ...msg,
          'active_version_index': versionIndex,
        };
      }
      return session.copyWith(messages: msgs, updatedAt: DateTime.now());
    }
    return session;
  }
}
