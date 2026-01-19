import 'package:dartantic_ai/dartantic_ai.dart' as dai;
import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/features/home/presentation/widgets/edit_message_sheet.dart';
import 'package:multigateway/features/home/services/message_helper.dart';

/// Service xử lý các thao tác trên message như edit, delete, version switch
class MessageOperationsService {
  /// Xóa message từ session
  static Future<void> deleteMessage({
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

  /// Mở dialog edit message
  static Future<void> openEditMessageDialog(
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

    await _applyMessageEdit(
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

  /// Áp dụng chỉnh sửa message
  static Future<void> _applyMessageEdit({
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
      dai.ChatMessage.model(
        newContent,
        metadata: {'files': newAttachments},
      ),
      files: newAttachments,
      reasoningContent: original.reasoningContent,
    );
    onSessionUpdate(session);

    if (resend && regenerateCallback != null) {
      regenerateCallback();
    }
  }

  /// Chuyển đổi version của message
  static Future<void> switchMessageVersion({
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

  /// Tìm index của user message cuối cùng trong regenerate
  static int findLastUserMessageIndex(List<StoredMessage> messages) {
    return MessageHelper.findLastUserMessageIndex(messages);
  }

  /// Lấy history messages đến một index nhất định
  static List<StoredMessage> getHistoryUpTo(
    List<StoredMessage> messages,
    int index,
  ) {
    return MessageHelper.getHistoryUpTo(messages, index);
  }

  /// Chuẩn bị base messages cho regenerate
  static List<StoredMessage> prepareBaseMessagesForRegenerate(
    List<StoredMessage> messages,
    int lastUserIndex,
    StoredMessage? existingModelMessage,
  ) {
    if (existingModelMessage != null) {
      return [...messages.take(lastUserIndex + 1), existingModelMessage];
    } else {
      return [...messages.take(lastUserIndex + 1)];
    }
  }
}
