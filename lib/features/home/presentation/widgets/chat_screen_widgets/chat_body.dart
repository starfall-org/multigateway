import 'package:flutter/material.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_messages_display.dart';
import 'package:multigateway/features/home/presentation/widgets/model_picker_sheet.dart';
import 'package:multigateway/features/home/presentation/widgets/quick_actions_sheet.dart';
import 'package:multigateway/features/home/presentation/widgets/user_input_area.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';

/// Body chính của chat screen
class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ChatControllerProvider.of(context);

    return Column(
      children: [
        // Danh sách tin nhắn
        Expanded(
          child: SafeArea(
            top: false,
            bottom: false,
            child: (controller.currentSession?.messages.isEmpty ?? true)
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: 'Start a conversation!',
                  )
                : ChatMessagesDisplay(
                    messages: controller.currentSession!.messages,
                    scrollController: controller.scrollController,
                    isGenerating: controller.isGenerating,
                    onCopy: (m) => controller.copyMessage(context, m),
                    onEdit: (m) => controller.openEditMessageDialog(context, m),
                    onDelete: (m) => controller.deleteMessage(m),
                    onOpenAttachmentsSidebar: (files) {
                      controller.openFilesDialog(files);
                    },
                    onRegenerate: () => controller.regenerateLast(context),
                    onRead: (m) =>
                        controller.speechManager.speak(m.content ?? ''),
                    onSwitchVersion: (m, idx) =>
                        controller.switchMessageVersion(m, idx),
                  ),
          ),
        ),
        // Khu vực nhập liệu
        SafeArea(
          top: false,
          child: UserInputArea(
            controller: controller.textController,
            onSubmitted: (text) => controller.handleSubmitted(text, context),
            attachments: controller.pendingFiles,
            onPickAttachments: () => controller.pickFromFiles(context),
            onPickFromGallery: () => controller.pickFromGallery(context),
            onRemoveAttachment: controller.removeAttachmentAt,
            isGenerating: controller.isGenerating,
            onOpenModelPicker: () => _openModelPicker(context, controller),
            onOpenMenu: () => QuickActionsSheet.show(context, controller),
            selectedLlmModel: controller.selectedLlmModel,
          ),
        ),
      ],
    );
  }

  void _openModelPicker(BuildContext context, controller) {
    ModelPickerSheet.show(
      context,
      providers: controller.providers,
      providerCollapsed: controller.providerCollapsed,
      providerModels: controller.modelSelectionController.providerModels,
      selectedProviderName: controller.selectedProviderName,
      selectedModelName: controller.selectedModelName,
      onToggleProvider: (providerName, collapsed) {
        controller.setProviderCollapsed(providerName, collapsed);
      },
      onSelectModel: (providerName, modelName) {
        controller.selectModel(providerName, modelName);
      },
    );
  }
}
