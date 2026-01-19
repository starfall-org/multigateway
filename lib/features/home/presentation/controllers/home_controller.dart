import 'package:flutter/material.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/home/presentation/controllers/attachment_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/message_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/model_selection_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/profile_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/session_controller.dart';
import 'package:multigateway/features/home/services/message_helper.dart';
import 'package:multigateway/features/home/services/provider_resolution_service.dart';
import 'package:multigateway/features/home/services/ui_navigation_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Main ChatController orchestrates all sub-controllers
class ChatController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatNavigationInterface navigator;
  final PreferencesStorage preferencesSp;
  final SpeechManager speechManager;

  // Sub-controllers - tên ngắn gọn
  final SessionController session;
  final MessageController message;
  final AttachmentController attachment;
  final ModelSelectionController model;
  final ProfileController profile;

  ChatController({
    required this.navigator,
    required ConversationStorage conversationRepository,
    required ChatProfileStorage chatProfileRepository,
    required LlmProviderInfoStorage llmProviderInfoStorage,
    required LlmProviderModelsStorage llmProviderModelsStorage,
    required this.preferencesSp,
    required McpInfoStorage mcpStorage,
    required this.speechManager,
    bool continueLastConversation = true,
  }) : session = SessionController(
         conversationRepository: conversationRepository,
         continueLastConversation: continueLastConversation,
       ),
       message = MessageController(),
       attachment = AttachmentController(),
       model = ModelSelectionController(
         pInfStorage: llmProviderInfoStorage,
         pModStorage: llmProviderModelsStorage,
       ),
       profile = ProfileController(
         chatProfileRepository: chatProfileRepository,
         mcpStorage: mcpStorage,
       );

  Future<void> initChat() => session.initChat();
  Future<void> createNewSession() => session.createNewSession();
  Future<void> loadSession(String sessionId) => session.loadSession(sessionId);

  Future<void> loadSelectedProfile() => profile.loadSelectedProfile();
  Future<void> updateProfile(ChatProfile p) => profile.updateProfile(p);
  Future<void> loadMcpClients() => profile.loadMcpClients();

  Future<void> refreshProviders() => model.refreshProviders();

  void setProviderCollapsed(String providerName, bool collapsed) =>
      model.setProviderCollapsed(providerName, collapsed);

  void selectModel(String providerName, String modelName) =>
      model.selectModel(providerName, modelName);

  Future<void> pickFromFiles(BuildContext context) =>
      attachment.pickFromFiles(context);

  Future<void> pickFromGallery(BuildContext context) =>
      attachment.pickFromGallery(context);

  void removeAttachmentAt(int index) => attachment.removeAttachmentAt(index);

  void openFilesDialog(List<String> attachments) =>
      attachment.openFilesDialog(attachments);

  void openEndDrawer() => navigator.openEndDrawer();

  Future<void> handleSubmitted(String text, BuildContext context) async {
    final currentSession = session.currentSession.value;
    final pendingFiles = attachment.pendingFiles.value;

    if (((text.trim().isEmpty) && pendingFiles.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingFiles);
    textController.clear();
    attachment.clearPendingAttachments();

    if (!context.mounted) return;

    final resolved = await ProviderResolutionService.resolveProviderAndModel(
      selectedProviderName: model.selectedProviderName.value,
      selectedModelName: model.selectedModelName.value,
      currentSession: currentSession,
    );

    final p =
        profile.selectedProfile.value ??
        ProviderResolutionService.createDefaultProfile();

    try {
      await message.sendMessage(
        text: text,
        attachments: attachments,
        currentSession: currentSession,
        profile: p,
        providerName: resolved.providerName,
        modelName: resolved.modelName,
        enableStream: p.config.enableStream,
        onSessionUpdate: (s) {
          session.updateSession(s);
          session.saveCurrentSession();
        },
        onScrollToBottom: () =>
            UiNavigationService.scrollToBottom(scrollController),
        isNearBottom: () => UiNavigationService.isNearBottom(scrollController),
        allowedToolNames: null,
        context: context.mounted ? context : null,
      );
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  Future<void> regenerateLast(BuildContext context) async {
    final currentSession = session.currentSession.value;
    if (currentSession == null || !context.mounted) return;

    final resolved = await ProviderResolutionService.resolveProviderAndModel(
      selectedProviderName: model.selectedProviderName.value,
      selectedModelName: model.selectedModelName.value,
      currentSession: currentSession,
    );

    final p =
        profile.selectedProfile.value ??
        ProviderResolutionService.createDefaultProfile();

    final errorMessage = await message.regenerateLast(
      currentSession: currentSession,
      profile: p,
      providerName: resolved.providerName,
      modelName: resolved.modelName,
      enableStream: p.config.enableStream,
      onSessionUpdate: (s) {
        session.updateSession(s);
        session.saveCurrentSession();
      },
      onScrollToBottom: () =>
          UiNavigationService.scrollToBottom(scrollController),
      isNearBottom: () => UiNavigationService.isNearBottom(scrollController),
      allowedToolNames: null,
      context: context.mounted ? context : null,
    );

    if (errorMessage != null && context.mounted) {
      context.showErrorSnackBar(errorMessage);
    }
  }

  String getTranscript() {
    return session.getTranscript(
      profileName: profile.selectedProfile.value?.name,
    );
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    await UiNavigationService.copyTranscriptToClipboard(context, txt);
  }

  Future<void> clearChat() => session.clearChat();

  Future<void> copyMessage(BuildContext context, dynamic m) =>
      message.copyMessage(context, m);

  Future<void> deleteMessage(dynamic m) async {
    final currentSession = session.currentSession.value;
    if (currentSession == null) return;
    await message.deleteMessage(
      message: m,
      currentSession: currentSession,
      onSessionUpdate: (s) {
        session.updateSession(s);
        session.saveCurrentSession();
      },
    );
  }

  Future<void> openEditMessageDialog(BuildContext context, StoredMessage m) async {
    final currentSession = session.currentSession.value;
    if (currentSession == null) return;
    await message.openEditMessageDialog(context, m, currentSession, (s) {
      session.updateSession(s);
      session.saveCurrentSession();
    }, regenerateLast);
  }

  Future<void> switchMessageVersion(StoredMessage m, int index) async {
    final currentSession = session.currentSession.value;
    if (currentSession == null) return;
    await message.switchMessageVersion(
      message: m,
      index: index,
      currentSession: currentSession,
      onSessionUpdate: (s) {
        session.updateSession(s);
        session.saveCurrentSession();
      },
    );
  }

  void scrollToBottom() => UiNavigationService.scrollToBottom(scrollController);
  bool isNearBottom() => UiNavigationService.isNearBottom(scrollController);
  void openDrawer() => UiNavigationService.openDrawer(scaffoldKey);
  void closeEndDrawer() => UiNavigationService.closeEndDrawer(scaffoldKey);

  void dispose() {
    session.dispose();
    message.dispose();
    attachment.dispose();
    model.dispose();
    profile.dispose();
    textController.dispose();
    scrollController.dispose();
    speechManager.stop();
  }
}

abstract class ChatNavigationInterface {
  void showSnackBar(String message);

  Future<({String content, List<String> attachments, bool resend})?>
  showEditMessageDialog({
    required String initialContent,
    required List<String> initialAttachments,
  });

  void openDrawer();
  void openEndDrawer();
  void closeEndDrawer();

  String getTranslatedString(String key, {Map<String, String>? namedArgs});
}
