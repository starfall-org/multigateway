import 'package:flutter/material.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/home/presentation/controllers/attachment_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/message_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/model_selection_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/profile_controller.dart';
import 'package:multigateway/features/home/presentation/controllers/session_controller.dart';
import 'package:multigateway/features/home/services/provider_resolution_service.dart';
import 'package:multigateway/features/home/services/ui_navigation_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Main ChatController orchestrates all sub-controllers
class ChatController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatNavigationInterface navigator;
  final PreferencesStorage preferencesSp;
  final SpeechManager speechManager;

  // Sub-controllers
  late final SessionController sessionController;
  late final MessageController messageController;
  late final AttachmentController attachmentController;
  late final ModelSelectionController modelSelectionController;
  late final ProfileController profileController;

  ChatController({
    required this.navigator,
    required ConversationStorage conversationRepository,
    required ChatProfileStorage aiProfileRepository,
    required LlmProviderInfoStorage llmProviderInfoStorage,
    required LlmProviderModelsStorage llmProviderModelsStorage,
    required this.preferencesSp,
    required McpServerInfoStorage mcpServerStorage,
    required this.speechManager,
    bool continueLastConversation = true,
  }) {
    // Initialize sub-controllers
    sessionController = SessionController(
      conversationRepository: conversationRepository,
      continueLastConversation: continueLastConversation,
    );
    messageController = MessageController();
    attachmentController = AttachmentController();
    modelSelectionController = ModelSelectionController(
      pInfStorage: llmProviderInfoStorage,
      pModStorage: llmProviderModelsStorage,
    );
    profileController = ProfileController(
      aiProfileRepository: aiProfileRepository,
      mcpServerStorage: mcpServerStorage,
    );

    // Listen to sub-controllers changes
    sessionController.addListener(notifyListeners);
    messageController.addListener(notifyListeners);
    attachmentController.addListener(notifyListeners);
    modelSelectionController.addListener(notifyListeners);
    profileController.addListener(notifyListeners);
  }

  // Convenience getters for backward compatibility
  Conversation? get currentSession => sessionController.currentSession;
  ChatProfile? get selectedProfile => profileController.selectedProfile;
  bool get isLoading => sessionController.isLoading;
  bool get isGenerating => messageController.isGenerating;
  List<String> get pendingFiles => attachmentController.pendingFiles;
  List<String> get inspectingFiles => attachmentController.inspectingFiles;
  List<LlmProviderInfo> get providers => modelSelectionController.providers;
  List<McpServer> get mcpServers => profileController.mcpServers;
  Map<String, bool> get providerCollapsed =>
      modelSelectionController.providerCollapsed;
  String? get selectedProviderName =>
      modelSelectionController.selectedProviderName;
  String? get selectedModelName => modelSelectionController.selectedModelName;
  dynamic get selectedLlmModel => modelSelectionController.selectedLlmModel;

  Future<void> initChat() => sessionController.initChat();
  Future<void> createNewSession() => sessionController.createNewSession();
  Future<void> loadSession(String sessionId) =>
      sessionController.loadSession(sessionId);
  void clearLoadingState() => sessionController.clearLoadingState();

  Future<void> loadSelectedProfile() => profileController.loadSelectedProfile();
  Future<void> updateProfile(ChatProfile profile) =>
      profileController.updateProfile(profile);
  Future<void> loadMcpServers() => profileController.loadMcpServers();

  Future<void> refreshProviders() =>
      modelSelectionController.refreshProviders();
  void setProviderCollapsed(String providerName, bool collapsed) =>
      modelSelectionController.setProviderCollapsed(providerName, collapsed);

  Future<void> pickFromFiles(BuildContext context) =>
      attachmentController.pickFromFiles(context);
  Future<void> pickFromGallery(BuildContext context) =>
      attachmentController.pickFromGallery(context);
  void removeAttachmentAt(int index) =>
      attachmentController.removeAttachmentAt(index);
  void setInspectingAttachments(List<String> attachments) =>
      attachmentController.setInspectingAttachments(attachments);
  void openFilesDialog(List<String> attachments) =>
      attachmentController.openFilesDialog(attachments);
  void openEndDrawer() => navigator.openEndDrawer();

  void selectModel(String providerName, String modelName) {
    modelSelectionController.selectModel(providerName, modelName);
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && pendingFiles.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingFiles);
    textController.clear();
    attachmentController.clearPendingAttachments();

    if (!context.mounted) return;

    // Resolve provider and model using service
    final resolved = await ProviderResolutionService.resolveProviderAndModel(
      selectedProviderName: selectedProviderName,
      selectedModelName: selectedModelName,
      currentSession: currentSession,
    );

    final profile =
        selectedProfile ?? ProviderResolutionService.createDefaultProfile();

    try {
      await messageController.sendMessage(
        text: text,
        attachments: attachments,
        currentSession: currentSession!,
        profile: profile,
        providerName: resolved.providerName,
        modelName: resolved.modelName,
        enableStream: profile.config.enableStream,
        onSessionUpdate: (session) {
          sessionController.updateSession(session);
          // ignore: discarded_futures
          sessionController.saveCurrentSession();
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

    UiNavigationService.scrollToBottom(scrollController);
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (currentSession == null) return;
    if (!context.mounted) return;

    final resolved = await ProviderResolutionService.resolveProviderAndModel(
      selectedProviderName: selectedProviderName,
      selectedModelName: selectedModelName,
      currentSession: currentSession,
    );

    final profile =
        selectedProfile ?? ProviderResolutionService.createDefaultProfile();

    final errorMessage = await messageController.regenerateLast(
      currentSession: currentSession!,
      profile: profile,
      providerName: resolved.providerName,
      modelName: resolved.modelName,
      enableStream: profile.config.enableStream,
      onSessionUpdate: (session) {
        sessionController.updateSession(session);
        // ignore: discarded_futures
        sessionController.saveCurrentSession();
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
    return sessionController.getTranscript(profileName: selectedProfile?.name);
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    await UiNavigationService.copyTranscriptToClipboard(context, txt);
  }

  Future<void> clearChat() => sessionController.clearChat();

  Future<void> copyMessage(BuildContext context, dynamic message) =>
      messageController.copyMessage(context, message);

  Future<void> deleteMessage(dynamic message) async {
    if (currentSession == null) return;
    await messageController.deleteMessage(
      message: message,
      currentSession: currentSession!,
      onSessionUpdate: (session) {
        sessionController.updateSession(session);
        // ignore: discarded_futures
        sessionController.saveCurrentSession();
      },
    );
  }

  Future<void> openEditMessageDialog(
    BuildContext context,
    dynamic message,
  ) async {
    if (currentSession == null) return;
    await messageController.openEditMessageDialog(
      context,
      message,
      currentSession!,
      (session) {
        sessionController.updateSession(session);
        // ignore: discarded_futures
        sessionController.saveCurrentSession();
      },
      regenerateLast,
    );
  }

  Future<void> switchMessageVersion(ChatMessage message, int index) async {
    if (currentSession == null) return;
    await messageController.switchMessageVersion(
      message: message,
      index: index,
      currentSession: currentSession!,
      onSessionUpdate: (session) {
        sessionController.updateSession(session);
        // ignore: discarded_futures
        sessionController.saveCurrentSession();
      },
    );
  }

  // UI Actions
  void scrollToBottom() => UiNavigationService.scrollToBottom(scrollController);
  bool isNearBottom() => UiNavigationService.isNearBottom(scrollController);
  void openDrawer() => UiNavigationService.openDrawer(scaffoldKey);
  void closeEndDrawer() => UiNavigationService.closeEndDrawer(scaffoldKey);

  @override
  void dispose() {
    sessionController.removeListener(notifyListeners);
    messageController.removeListener(notifyListeners);
    attachmentController.removeListener(notifyListeners);
    modelSelectionController.removeListener(notifyListeners);
    profileController.removeListener(notifyListeners);

    sessionController.dispose();
    messageController.dispose();
    attachmentController.dispose();
    modelSelectionController.dispose();
    profileController.dispose();

    textController.dispose();
    scrollController.dispose();
    speechManager.stop();
    super.dispose();
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
