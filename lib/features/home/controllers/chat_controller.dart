import 'package:flutter/material.dart';

import '../../../core/models/ai/ai_profile.dart';
import '../../../core/models/ai/ai_model.dart';
import '../../../core/models/chat/message.dart';
import '../services/chat_service.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/storage/ai_profile_repository.dart';
import '../../../core/storage/chat_repository.dart';
import '../../../core/storage/provider_repository.dart';
import '../../../core/models/provider.dart';
import '../../../core/storage/app_preferences_repository.dart';
import '../../../core/storage/mcp_repository.dart';
import '../../../core/models/mcp/mcp_server.dart';
import '../services/tts_service.dart';
import '../../../core/translate.dart';
import '../widgets/edit_message_dialog.dart';
import 'chat_navigation_interface.dart';

import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../utils/chat_logic_utils.dart';

part 'chat_viewmodel_actions.dart';
part 'chat_message_actions.dart';
part 'chat_attachment_actions.dart';
part 'chat_operations.dart';
part 'chat_edit_actions.dart';
part 'chat_ui_actions.dart';

class ChatViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatNavigationInterface navigator;
  final ChatRepository chatRepository;
  final AIProfileRepository aiProfileRepository;
  final ProviderRepository providerRepository;
  final PreferencesSp PreferencesSp;
  final MCPRepository mcpRepository;
  final TTSService ttsService;

  StreamSubscription? _providerSubscription;
  Conversation? currentSession;
  AIProfile? selectedProfile;
  bool isLoading = true;
  bool isGenerating = false;

  final List<String> pendingAttachments = [];

  // Right sidebar: attachments to inspect
  final List<String> inspectingAttachments = [];

  // Providers and model selection state
  List<Provider> providers = [];
  List<MCPServer> mcpServers = [];
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderName;
  String? selectedModelName;

  AIModel? get selectedAIModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.name == selectedProviderName,
      );
      return provider.models.firstWhere((m) => m.name == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  ChatViewModel({
    required this.navigator,
    required this.chatRepository,
    required this.aiProfileRepository,
    required this.providerRepository,
    required this.PreferencesSp,
    required this.mcpRepository,
    required this.ttsService,
  }) {
    _providerSubscription = providerRepository.changes.listen((_) {
      refreshProviders();
    });
  }

  void notify() => notifyListeners();

  Future<void> initChat() async {
    final sessions = chatRepository.getConversations();

    if (sessions.isNotEmpty) {
      currentSession = sessions.first;
      isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
  }

  Future<void> loadSelectedProfile() async {
    final profile = await aiProfileRepository.getOrInitSelectedProfile();
    selectedProfile = profile;
    notifyListeners();
  }

  Future<void> updateProfile(AIProfile profile) async {
    selectedProfile = profile;
    await aiProfileRepository.updateProfile(profile);
    notifyListeners();
  }

  Future<void> loadMCPServers() async {
    mcpServers = mcpRepository.getItems().whereType<MCPServer>().toList();
    notifyListeners();
  }

  Future<void> refreshProviders() async {
    providers = providerRepository.getProviders();
    // Initialize collapse map entries for unseen providers
    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  bool shouldPersistSelections() {
    final prefs = PreferencesSp.currentPreferences;
    // If preferAgentSettings is on and profile has an override, use it
    if (selectedProfile?.persistChatSelection != null) {
      return selectedProfile!.persistChatSelection!;
    }
    return prefs.persistChatSelection;
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName = providerName;
    selectedModelName = modelName;

    // Persist selection into current conversation if preference allows
    if (currentSession != null && shouldPersistSelections()) {
      currentSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      // ignore: discarded_futures
      chatRepository.saveConversation(currentSession!);
    }

    notifyListeners();
  }

  Future<void> createNewSession() async {
    final session = await chatRepository.createConversation();
    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    isLoading = true;
    notifyListeners();

    final sessions = chatRepository.getConversations();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  // Clear loading state (useful for error recovery)
  void clearLoadingState() {
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _providerSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    ttsService.stop();
    super.dispose();
  }
}
