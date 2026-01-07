import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:llm/llm.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/core/mcp/storage/mcp_server_info_storage.dart';
import 'package:multigateway/features/home/domain/domain.dart';
import 'package:multigateway/features/home/ui/controllers/attachment_controller.dart';
import 'package:multigateway/features/home/ui/controllers/chat_controller_parts/chat_navigation_interface.dart';
import 'package:multigateway/features/home/ui/controllers/message_controller.dart';
import 'package:multigateway/features/home/ui/controllers/model_selection_controller.dart';
import 'package:multigateway/features/home/ui/controllers/profile_controller.dart';
// Import các controller con
import 'package:multigateway/features/home/ui/controllers/session_controller.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:uuid/uuid.dart';

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
    required this.preferencesSp,
    required McpServerInfoStorage mcpServerStorage,
    required this.speechManager,
  }) {
    // Initialize sub-controllers
    sessionController = SessionController(conversationRepository: conversationRepository);
    messageController = MessageController();
    attachmentController = AttachmentController();
    modelSelectionController = ModelSelectionController(
      llmProviderInfoStorage: llmProviderInfoStorage,
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
  List<String> get pendingAttachments =>
      attachmentController.pendingAttachments;
  List<String> get inspectingAttachments =>
      attachmentController.inspectingAttachments;
  List<Provider> get providers => modelSelectionController.providers;
  List<McpServer> get mcpServers => profileController.mcpServers;
  Map<String, bool> get providerCollapsed =>
      modelSelectionController.providerCollapsed;
  String? get selectedProviderName =>
      modelSelectionController.selectedProviderName;
  String? get selectedModelName => modelSelectionController.selectedModelName;
  dynamic get selectedAIModel => modelSelectionController.selectedAIModel;

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

  Future<void> pickAttachments(BuildContext context) =>
      attachmentController.pickAttachments(context);
  Future<void> pickAttachmentsFromGallery(BuildContext context) =>
      attachmentController.pickAttachmentsFromGallery(context);
  void removeAttachmentAt(int index) =>
      attachmentController.removeAttachmentAt(index);
  void setInspectingAttachments(List<String> attachments) =>
      attachmentController.setInspectingAttachments(attachments);
  void openAttachmentsSidebar(List<String> attachments) =>
      attachmentController.openAttachmentsSidebar(attachments);
  void openEndDrawer() => navigator.openEndDrawer();

  bool shouldPersistSelections() {
    final prefs = preferencesSp.currentPreferences;
    if (selectedProfile?.persistChatSelection != null) {
      return selectedProfile!.persistChatSelection!;
    }
    return prefs.persistChatSelection;
  }

  void selectModel(String providerName, String modelName) {
    modelSelectionController.selectModel(providerName, modelName);

    // Persist selection into current conversation if preference allows
    if (currentSession != null && shouldPersistSelections()) {
      final updatedSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      sessionController.updateSession(updatedSession);
      // ignore: discarded_futures
      sessionController.saveCurrentSession();
    }
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && pendingAttachments.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingAttachments);
    textController.clear();
    attachmentController.clearPendingAttachments();

    // Resolve provider and model
    final providerRepo = await LlmProviderInfoStorage.init();
    if (!context.mounted) return;

    final providersList = providerRepo.getItems();
    final persist = shouldPersistSelections();

    final selection = ChatLogicUtils.resolveProviderAndModel(
      currentSession: currentSession,
      persistSelection: persist,
      selectedProvider: selectedProviderName,
      selectedModel: selectedModelName,
      providers: providersList,
    );

    final providerName = selection.provider;
    final modelName = selection.model;

    // If persistence is enabled and not loaded from session, store selection
    if (currentSession != null &&
        persist &&
        (currentSession!.providerId.isEmpty ||
            currentSession!.modelName.isEmpty)) {
      final updatedSession = currentSession!.copyWith(
        providerId: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      sessionController.updateSession(updatedSession);
      await sessionController.saveCurrentSession();
    }

    final profile =
        selectedProfile ??
        ChatProfile(
          id: const Uuid().v4(),
          name: 'Default Profile',
          config: LlmChatConfig(systemPrompt: '', enableStream: true),
        );

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      allowedToolNames = await profileController.snapshotEnabledToolNames(profile);
    }

    if (!context.mounted) return;

    try {
      await messageController.sendMessage(
        text: text,
        attachments: attachments,
        currentSession: currentSession!,
        profile: profile,
        providerName: providerName,
        modelName: modelName,
        enableStream: profile.config.enableStream,
        onSessionUpdate: (session) {
          sessionController.updateSession(session);
          // ignore: discarded_futures
          sessionController.saveCurrentSession();
        },
        onScrollToBottom: scrollToBottom,
        isNearBottom: isNearBottom,
        allowedToolNames: allowedToolNames,
        context: context,
      );
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }

    scrollToBottom();
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (currentSession == null) return;

    final providerRepo = await LlmProviderInfoStorage.init();
    if (!context.mounted) return;

    final providersList = providerRepo.getItems();
    final persist = shouldPersistSelections();

    final selection = ChatLogicUtils.resolveProviderAndModel(
      currentSession: currentSession,
      persistSelection: persist,
      selectedProvider: selectedProviderName,
      selectedModel: selectedModelName,
      providers: providersList,
    );

    final providerName = selection.provider;
    final modelName = selection.model;

    if (currentSession != null &&
        persist &&
        (currentSession!.providerId.isEmpty ||
            currentSession!.modelName.isEmpty)) {
      final updatedSession = currentSession!.copyWith(
        providerId: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      sessionController.updateSession(updatedSession);
      await sessionController.saveCurrentSession();
    }

    final profile =
        selectedProfile ??
        ChatProfile(
          id: const Uuid().v4(),
          name: 'Default Profile',
          config: LlmChatConfig(systemPrompt: '', enableStream: true),
        );

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      allowedToolNames = await profileController.snapshotEnabledToolNames(profile);
    }

    if (!context.mounted) return;

    final errorMessage = await messageController.regenerateLast(
      currentSession: currentSession!,
      profile: profile,
      providerName: providerName,
      modelName: modelName,
      enableStream: profile.config.enableStream,
      onSessionUpdate: (session) {
        sessionController.updateSession(session);
        // ignore: discarded_futures
        sessionController.saveCurrentSession();
      },
      onScrollToBottom: scrollToBottom,
      isNearBottom: isNearBottom,
      allowedToolNames: allowedToolNames,
      context: context,
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
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));

    if (context.mounted) {
      context.showSuccessSnackBar(tl('Transcript copied'));
    }
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
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool isNearBottom() {
    if (!scrollController.hasClients) return true;
    final position = scrollController.position;
    return position.pixels >= position.maxScrollExtent - 100;
  }

  void openDrawer() {
    navigator.openDrawer();
  }

  void closeEndDrawer() {
    navigator.closeEndDrawer();
  }

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
