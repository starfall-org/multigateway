import 'package:dartantic_ai/dartantic_ai.dart' as dai;
import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/presentation/widgets/edit_message_sheet.dart';
import 'package:multigateway/features/home/services/message_helper.dart';
import 'package:multigateway/features/home/services/message_stream_service.dart';
import 'package:multigateway/features/home/services/ui_navigation_service.dart';
import 'package:multigateway/features/home/utils/chat_logic_utils.dart';
import 'package:signals/signals.dart';

/// Controller responsible for message operations
class MessageController {
  final isGenerating = signal<bool>(false);

  void setGenerating(bool value) {
    isGenerating.value = value;
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
    final userMessage = MessageHelper.createUserMessage(text, attachments);
    var session = MessageHelper.addMessageToSession(
      currentSession,
      userMessage,
    );

    isGenerating.value = true;

    // Generate title if first message
    if (session.messages.length == 1) {
      final title = ChatLogicUtils.generateTitle(text, attachments);
      session = session.copyWith(title: title);
    }

    onSessionUpdate(session);
    onScrollToBottom();

    final modelInput = ChatLogicUtils.formatFilesForPrompt(text, attachments);

    try {
      if (enableStream) {
        await MessageStreamService.handleStreamResponse(
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
        await MessageStreamService.handleNonStreamResponse(
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
    } finally {
      isGenerating.value = false;
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
    final lastUserIndex = MessageHelper.findLastUserMessageIndex(msgs);

    if (lastUserIndex == -1) {
      return tl('No user message found to regenerate');
    }

    final userMessage = msgs[lastUserIndex];
    final userText = ChatLogicUtils.formatFilesForPrompt(
      userMessage.content ?? '',
      userMessage.files,
    );
    final history = MessageHelper.getHistoryUpTo(msgs, lastUserIndex);

    // Check if there's an existing model response following the last user message
    StoredMessage? existingModelMessage;
    if (lastUserIndex < msgs.length - 1) {
      final next = msgs[lastUserIndex + 1];
      if (next.role == ChatRole.model) {
        existingModelMessage = next;
      }
    }

    isGenerating.value = true;

    try {
      // Preserve the message list up to the user message, plus the model message if we are regenerating it
      final List<StoredMessage> baseMessages;
      if (existingModelMessage != null) {
        baseMessages = [...msgs.take(lastUserIndex + 1), existingModelMessage];
      } else {
        baseMessages = [...msgs.take(lastUserIndex + 1)];
      }

      var session = MessageHelper.updateSessionWithMessages(
        currentSession,
        baseMessages,
      );

      if (enableStream) {
        await MessageStreamService.handleStreamResponse(
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
        await MessageStreamService.handleNonStreamResponse(
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
    } finally {
      isGenerating.value = false;
    }
  }

  void dispose() {
    isGenerating.dispose();
  }

  Future<void> copyMessage(BuildContext context, StoredMessage message) async {
    await UiNavigationService.copyMessageToClipboard(context, message.content);
  }

  Future<void> deleteMessage({
    required StoredMessage message,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
  }) async {
    final session = MessageHelper.removeMessageFromSession(
      currentSession,
      message.id,
    );
    onSessionUpdate(session);
  }

  Future<void> openEditMessageDialog(
    BuildContext context,
    StoredMessage message,
    Conversation currentSession,
    Function(Conversation) onSessionUpdate,
    Function(BuildContext) regenerateCallback,
  ) async {
    final result = await EditMessageSheet.show(
      context,
      initialContent: message.content ?? '',
      initialAttachments: message.files,
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
    required StoredMessage original,
    required String newContent,
    required List<String> newAttachments,
    bool resend = false,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
    Function()? regenerateCallback,
  }) async {
    final session = MessageHelper.addVersionToMessageInSession(
      currentSession,
      original.id,
      dai.ChatMessage.model(newContent, metadata: {'files': newAttachments}),
      files: newAttachments,
      reasoningContent: original.reasoningContent,
    );
    onSessionUpdate(session);

    if (resend && regenerateCallback != null) {
      regenerateCallback();
    }
  }

  Future<void> switchMessageVersion({
    required StoredMessage message,
    required int index,
    required Conversation currentSession,
    required Function(Conversation) onSessionUpdate,
  }) async {
    final session = MessageHelper.switchMessageVersionInSession(
      currentSession,
      message.id,
      index,
    );
    onSessionUpdate(session);
  }
}
