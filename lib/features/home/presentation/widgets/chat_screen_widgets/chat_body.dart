import 'package:flutter/material.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_messages_display.dart';
import 'package:multigateway/features/home/presentation/widgets/model_picker_sheet.dart';
import 'package:multigateway/features/home/presentation/widgets/quick_actions_sheet.dart';
import 'package:multigateway/features/home/presentation/widgets/user_input_area.dart';
import 'package:multigateway/shared/widgets/empty_state.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = ChatControllerProvider.of(context);

    return Watch((context) {
      final currentSession = ctrl.session.currentSession.value;
      final isGenerating = ctrl.message.isGenerating.value;
      final pendingFiles = ctrl.attachment.pendingFiles.value;

      return Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: (currentSession?.messages.isEmpty ?? true)
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      message: 'Start a conversation!',
                    )
                  : ChatMessagesDisplay(
                      messages: currentSession!.messages,
                      scrollController: ctrl.scrollController,
                      isGenerating: isGenerating,
                      onCopy: (m) => ctrl.copyMessage(context, m),
                      onEdit: (m) => ctrl.openEditMessageDialog(context, m),
                      onDelete: (m) => ctrl.deleteMessage(m),
                      onOpenAttachmentsSidebar: (files) =>
                          ctrl.openFilesDialog(files),
                      onRegenerate: () => ctrl.regenerateLast(context),
                      onRead: (m) => ctrl.speechManager.speak(m.content ?? ''),
                      onSwitchVersion: (m, idx) =>
                          ctrl.switchMessageVersion(m, idx),
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: UserInputArea(
              controller: ctrl.textController,
              onSubmitted: (text) => ctrl.handleSubmitted(text, context),
              attachments: pendingFiles,
              onPickAttachments: () => ctrl.pickFromFiles(context),
              onPickFromGallery: () => ctrl.pickFromGallery(context),
              onRemoveAttachment: ctrl.removeAttachmentAt,
              isGenerating: isGenerating,
              onOpenModelPicker: () => _openModelPicker(context, ctrl),
              onOpenMenu: () => QuickActionsSheet.show(context, ctrl),
              selectedLlmModel: ctrl.model.selectedLlmModel,
            ),
          ),
        ],
      );
    });
  }

  void _openModelPicker(BuildContext context, ctrl) {
    ModelPickerSheet.show(
      context,
      providers: ctrl.model.providers.value,
      providerCollapsed: ctrl.model.providerCollapsed.value,
      providerModels: ctrl.model.providerModels.value,
      selectedProviderName: ctrl.model.selectedProviderName.value,
      selectedModelName: ctrl.model.selectedModelName.value,
      onToggleProvider: (providerName, collapsed) {
        ctrl.setProviderCollapsed(providerName, collapsed);
      },
      onSelectModel: (providerName, modelName) {
        ctrl.selectModel(providerName, modelName);
      },
    );
  }
}
