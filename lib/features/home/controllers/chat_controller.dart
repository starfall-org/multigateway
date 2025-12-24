import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../core/models/chat/message.dart';
import '../../../shared/translate/tl.dart';
import '../../../core/data/ai_profile_store.dart';
import '../../../core/data/chat_store.dart';
import '../../../core/data/mcpserver_store.dart';
import '../../../core/data/ai_provider_store.dart';
import '../../../core/models/ai/model.dart';
import '../../../core/models/ai/profile.dart';
import '../../../core/models/ai/provider.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/models/mcp/mcp_server.dart';
import '../../../shared/prefs/preferences.dart';
import '../services/chat_service.dart';
import '../services/tts_service.dart';
import '../ui/widgets/edit_message_sheet.dart';
import '../utils/chat_logic_utils.dart';
import 'chat_controller_parts/chat_navigation_interface.dart';

part 'chat_controller_parts/chat_viewmodel_actions.dart';
part 'chat_controller_parts/chat_message_actions.dart';
part 'chat_controller_parts/chat_attachment_actions.dart';
part 'chat_controller_parts/chat_operations.dart';
part 'chat_controller_parts/chat_edit_actions.dart';
part 'chat_controller_parts/chat_ui_actions.dart';

class ChatController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final ChatNavigationInterface navigator;
  final ChatRepository chatRepository;
  final AIProfileRepository aiProfileRepository;
  final ProviderRepository providerRepository;
  final PreferencesSp preferencesSp;
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

  ChatController({
    required this.navigator,
    required this.chatRepository,
    required this.aiProfileRepository,
    required this.providerRepository,
    required this.preferencesSp,
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
    final prefs = preferencesSp.currentPreferences;
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
