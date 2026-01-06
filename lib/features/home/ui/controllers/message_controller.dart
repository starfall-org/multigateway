import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/domain/domain.dart';
import 'package:multigateway/features/home/ui/widgets/edit_message_sheet.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/error_debug_dialog.dart';
import 'package:uuid/uuid.dart';

/// Controller responsible for message operations
class MessageController extends ChangeNotifier {
  bool isGenerating = false;

  void setGenerating(bool value) {
    isGenerating = value;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required List<String> attachments,
    required Conversation currentSession,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required bool enableStream,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
    BuildContext? context,
  }) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    var session = currentSession.copyWith(
      messages: [...currentSession.messages, userMessage],
      updatedAt: DateTime.now(),
    );

    isGenerating = true;
    notifyListeners();

    // Generate title if first message
    if (session.messages.length == 1) {
      final title = ChatLogicUtils.generateTitle(text, attachments);
      session = session.copyWith(title: title);
    }

    onSessionUpdate(session);

    final modelInput = ChatLogicUtils.formatAttachmentsForPrompt(
      text,
      attachments,
    );

    if (enableStream) {
      await _handleStreamResponse(
        userText: modelInput,
        history: session.messages.take(session.messages.length - 1).toList(),
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        isNearBottom: isNearBottom,
        allowedToolNames: allowedToolNames,
        context: context,
      );
    } else {
      await _handleNonStreamResponse(
        userText: modelInput,
        history: session.messages.take(session.messages.length - 1).toList(),
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        currentSession: session,
        onSessionUpdate: onSessionUpdate,
        onScrollToBottom: onScrollToBottom,
        allowedToolNames: allowedToolNames,
        context: context,
      );
    }
  }

  Future<void> _handleStreamResponse({
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
      final idx = session.messages.indexWhere((m) => m.id == modelId);
      if (idx != -1) {
        final existing = session.messages[idx];
        final withNewVersion = existing.addVersion(
          MessageContents(content: '', timestamp: DateTime.now()),
        );
        final msgs = List<ChatMessage>.from(session.messages);
        msgs[idx] = withNewVersion;
        session = session.copyWith(messages: msgs, updatedAt: DateTime.now());
      }
    } else {
      modelId = const Uuid().v4();
      final placeholder = ChatMessage(
        id: modelId,
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      );
      session = session.copyWith(
        messages: [...session.messages, placeholder],
        updatedAt: DateTime.now(),
      );
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

        final msgs = List<ChatMessage>.from(session.messages);
        final idx = msgs.indexWhere((m) => m.id == modelId);
        if (idx != -1) {
          final old = msgs[idx];
          msgs[idx] = old.updateActiveContent(acc);
          session = session.copyWith(messages: msgs, updatedAt: DateTime.now());
          onSessionUpdate(session);

          if (wasAtBottom) {
            onScrollToBottom();
          }
          lastUpdate = now;
        }
      }

      // Final update
      final msgs = List<ChatMessage>.from(session.messages);
      final idx = msgs.indexWhere((m) => m.id == modelId);
      if (idx != -1) {
        final old = msgs[idx];
        if (old.content != acc) {
          msgs[idx] = old.updateActiveContent(acc);
          session = session.copyWith(messages: msgs, updatedAt: DateTime.now());
          onSessionUpdate(session);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _handleStreamResponse: $e');
      debugPrint(stackTrace.toString());

      if (context != null && context.mounted) {
        if (PreferencesStorage.instance.currentPreferences.debugMode) {
          ErrorDebugDialog.show(context, error: e, stackTrace: stackTrace);
        }
      }
      rethrow;
    } finally {
      isGenerating = false;
      notifyListeners();
      if (isNearBottom()) {
        onScrollToBottom();
      }
    }
  }

  Future<void> _handleNonStreamResponse({
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
        final idx = session.messages.indexWhere(
          (m) => m.id == existingMessageId,
        );
        if (idx != -1) {
          final existing = session.messages[idx];
          final updated = existing.addVersion(
            MessageContents(content: reply, timestamp: DateTime.now()),
          );
          final msgs = List<ChatMessage>.from(session.messages);
          msgs[idx] = updated;
          session = session.copyWith(messages: msgs, updatedAt: DateTime.now());
        }
      } else {
        final modelMessage = ChatMessage(
          id: const Uuid().v4(),
          role: ChatRole.model,
          content: reply,
          timestamp: DateTime.now(),
        );
        session = session.copyWith(
          messages: [...session.messages, modelMessage],
          updatedAt: DateTime.now(),
        );
      }

      onSessionUpdate(session);
    } catch (e, stackTrace) {
      debugPrint('Error in _handleNonStreamResponse: $e');
      debugPrint(stackTrace.toString());

      if (context != null && context.mounted) {
        if (PreferencesStorage.instance.currentPreferences.debugMode) {
          ErrorDebugDialog.show(context, error: e, stackTrace: stackTrace);
        }
      }
      rethrow;
    } finally {
      isGenerating = false;
      notifyListeners();
      onScrollToBottom();
    }
  }

  Future<String?> regenerateLast({
    required Conversation currentSession,
    required ChatProfile profile,
    required String providerName,
    required String modelName,
    required bool enableStream,
    required Function(Conversation) onSessionUpdate,
    required Function() onScrollToBottom,
    required Function() isNearBottom,
    List<String>? allowedToolNames,
    BuildContext? context,
  }) async {
    if (currentSession.messages.isEmpty) return null;

    final msgs = currentSession.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }

    if (lastUserIndex == -1) {
      return tl('No user message found to regenerate');
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    // Check if there's an existing model response following the last user message
    ChatMessage? existingModelMessage;
    if (lastUserIndex < msgs.length - 1) {
      final next = msgs[lastUserIndex + 1];
      if (next.role == ChatRole.model) {
        existingModelMessage = next;
      }
    }

    isGenerating = true;
    notifyListeners();

    try {
      // Preserve the message list up to the user message, plus the model message if we are regenerating it
      final List<ChatMessage> baseMessages;
      if (existingModelMessage != null) {
        baseMessages = [...msgs.take(lastUserIndex + 1), existingModelMessage];
      } else {
        baseMessages = [...msgs.take(lastUserIndex + 1)];
      }

      var session = currentSession.copyWith(
        messages: baseMessages,
        updatedAt: DateTime.now(),
      );

      if (enableStream) {
        await _handleStreamResponse(
          userText: userText,
          history: history,
          profile: profile,
          providerName: providerName,
          modelName: modelName,
          currentSession: session,
          onSessionUpdate: onSessionUpdate,
          onScrollToBottom: onScrollToBottom,
          isNearBottom: isNearBottom,
          allowedToolNames: allowedToolNames,
          existingMessageId: existingModelMessage?.id,
          context: context,
        );
      } else {
        await _handleNonStreamResponse(
          userText: userText,
          history: history,
          profile: profile,
          providerName: providerName,
          modelName: modelName,
          currentSession: session,
          onSessionUpdate: onSessionUpdate,
          onScrollToBottom: onScrollToBottom,
          allowedToolNames: allowedToolNames,
          existingMessageId: existingModelMessage?.id,
          context: context,
        );
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> copyMessage(BuildContext context, ChatMessage message) async {
    if (message.content.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      context.showSuccessSnackBar(tl('Transcript copied'));
    }
  }

  Future<void> deleteMessage({
    required ChatMessage message,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
  }) async {
    final msgs = List<ChatMessage>.from(currentSession.messages)
      ..removeWhere((m) => m.id == message.id);

    final session = currentSession.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );

    onSessionUpdate(session);
  }

  Future<void> openEditMessageDialog(
    BuildContext context,
    ChatMessage message,
    Conversation currentSession,
    Function(Conversation) onSessionUpdate,
    Function(BuildContext) regenerateCallback,
  ) async {
    final result = await EditMessageSheet.show(
      context,
      initialContent: message.content,
      initialAttachments: message.attachments,
    );
    if (result == null) return;
    if (!context.mounted) return;

    await applyMessageEdit(
      original: message,
      newContent: result.content,
      newAttachments: result.attachments,
      resend: result.resend,
      currentSession: currentSession,
      onSessionUpdate: onSessionUpdate,
      regenerateCallback: result.resend
          ? () => regenerateCallback(context)
          : null,
    );
  }

  Future<void> applyMessageEdit({
    required ChatMessage original,
    required String newContent,
    required List<String> newAttachments,
    bool resend = false,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    Function()? regenerateCallback,
  }) async {
    final msgs = List<ChatMessage>.from(currentSession.messages);
    final idx = msgs.indexWhere((m) => m.id == original.id);
    if (idx == -1) return;

    final updated = original.addVersion(
      MessageContents(
        content: newContent,
        timestamp: DateTime.now(),
        attachments: newAttachments,
        reasoningContent: original.reasoningContent,
        files: original.files,
      ),
    );
    msgs[idx] = updated;

    final session = currentSession.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );

    onSessionUpdate(session);

    if (resend && regenerateCallback != null) {
      regenerateCallback();
    }
  }

  Future<void> switchMessageVersion({
    required ChatMessage message,
    required int index,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
  }) async {
    final msgs = List<ChatMessage>.from(currentSession.messages);
    final idx = msgs.indexWhere((m) => m.id == message.id);
    if (idx == -1) return;

    msgs[idx] = message.switchVersion(index);

    final session = currentSession.copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );

    onSessionUpdate(session);
  }
}
