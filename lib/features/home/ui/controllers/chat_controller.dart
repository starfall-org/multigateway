import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/profile/data/ai_profile_store.dart';
import '../../domain/data/chat_store.dart';
import '../../../../core/mcp/data/mcpserver_store.dart';
import '../../../../core/llm/data/provider_info_storage.dart';
import '../../../../core/profile/models/profile.dart';
import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../../../core/mcp/models/mcp_server.dart';
import '../../../../app/data/preferences.dart';
import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/utils/chat_logic_utils.dart';
import 'chat_controller_parts/chat_navigation_interface.dart';

// Import các controller con
import 'session_controller.dart';
import 'message_controller.dart';
import 'attachment_controller.dart';
import 'model_selection_controller.dart';
import 'profile_controller.dart';

/// Main ChatController orchestrates all sub-controllers
class ChatController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatNavigationInterface navigator;
  final PreferencesSp preferencesSp;
  final TTSService ttsService;

  // Sub-controllers
  late final SessionController sessionController;
  late final MessageController messageController;
  late final AttachmentController attachmentController;
  late final ModelSelectionController modelSelectionController;
  late final ProfileController profileController;

  ChatController({
    required this.navigator,
    required ChatRepository chatRepository,
    required AIProfileRepository aiProfileRepository,
    required ProviderInfoStorage pInfStorage,
    required this.preferencesSp,
    required MCPRepository mcpRepository,
    required this.ttsService,
  }) {
    // Initialize sub-controllers
    sessionController = SessionController(chatRepository: chatRepository);
    messageController = MessageController();
    attachmentController = AttachmentController();
    modelSelectionController = ModelSelectionController(
      pInfStorage: pInfStorage,
    );
    profileController = ProfileController(
      aiProfileRepository: aiProfileRepository,
      mcpRepository: mcpRepository,
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
  AIProfile? get selectedProfile => profileController.selectedProfile;
  bool get isLoading => sessionController.isLoading;
  bool get isGenerating => messageController.isGenerating;
  List<String> get pendingAttachments =>
      attachmentController.pendingAttachments;
  List<String> get inspectingAttachments =>
      attachmentController.inspectingAttachments;
  List<Provider> get providers => modelSelectionController.providers;
  List<MCPServer> get mcpServers => profileController.mcpServers;
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
  Future<void> updateProfile(AIProfile profile) =>
      profileController.updateProfile(profile);
  Future<void> loadMCPServers() => profileController.loadMCPServers();

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
    final providerRepo = await ProviderInfoStorage.init();
    if (!context.mounted) return;

    final providersList = providerRepo.getProviders();
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
        (currentSession!.providerName == null ||
            currentSession!.modelName == null)) {
      final updatedSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      sessionController.updateSession(updatedSession);
      await sessionController.saveCurrentSession();
    }

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        final profile =
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: AiConfig(systemPrompt: '', enableStream: true),
            );
        final names = await profileController.snapshotEnabledToolNames(profile);
        final updatedSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        sessionController.updateSession(updatedSession);
        await sessionController.saveCurrentSession();
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final profile =
        selectedProfile ??
        AIProfile(
          id: const Uuid().v4(),
          name: 'Default Profile',
          config: AiConfig(systemPrompt: '', enableStream: true),
        );

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

    final providerRepo = await ProviderInfoStorage.init();
    if (!context.mounted) return;

    final providersList = providerRepo.getProviders();
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
        (currentSession!.providerName == null ||
            currentSession!.modelName == null)) {
      final updatedSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      sessionController.updateSession(updatedSession);
      await sessionController.saveCurrentSession();
    }

    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        final profile =
            selectedProfile ??
            AIProfile(
              id: const Uuid().v4(),
              name: 'Default Profile',
              config: AiConfig(systemPrompt: '', enableStream: true),
            );
        final names = await profileController.snapshotEnabledToolNames(profile);
        final updatedSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        sessionController.updateSession(updatedSession);
        await sessionController.saveCurrentSession();
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final profile =
        selectedProfile ??
        AIProfile(
          id: const Uuid().v4(),
          name: 'Default Profile',
          config: AiConfig(systemPrompt: '', enableStream: true),
        );

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

  Future<void> speakLastModelMessage() async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;
    final lastModel = currentSession!.messages.lastWhere(
      (m) => m.role == ChatRole.model,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastModel.content.isEmpty) return;
    await ttsService.speak(lastModel.content);
  }

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

  void openEndDrawer() {
    navigator.openEndDrawer();
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
    ttsService.stop();
    super.dispose();
  }
}
