import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/ai_profile_repository.dart';
import '../../../../core/storage/mcp_repository.dart';
import '../../../../core/models/ai/ai_profile.dart';
import '../../../../core/models/mcp/mcp_server.dart';

import '../../../../core/translate.dart';

/// Options for chat persistence: On, Off, and Disable
/// - On: Enable chat persistence
/// - Off: Disable chat persistence but follow global setting
/// - Disable: Force disable chat persistence (overrides global setting)
enum PersistOverride { on, off, disable }

class AddAgentViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promptController = TextEditingController();

  // State variables representing all fields of AIProfile
  bool enableStream = true;
  bool isTopPEnabled = false;
  double topPValue = 1.0;
  bool isTopKEnabled = false;
  double topKValue = 40.0;
  bool isTemperatureEnabled = false;
  double temperatureValue = 0.7;
  int contextWindowValue = 60000;
  int conversationLengthValue = 10;
  int maxTokensValue = 4000;
  bool isCustomThinkingTokensEnabled = false;
  int customThinkingTokensValue = 0;
  ThinkingLevel thinkingLevel = ThinkingLevel.auto;
  bool profileConversations = false;
  List<MCPServer> availableMCPServers = [];
  final List<String> selectedMCPServerIds = [];
  PersistOverride persistOverride = PersistOverride.off;

  // Initialize with optional existing profile
  void initialize(AIProfile? profile) {
    if (profile != null) {
      nameController.text = profile.name;
      promptController.text = profile.config.systemPrompt;
      enableStream = profile.config.enableStream;

      if (profile.config.topP != null) {
        isTopPEnabled = true;
        topPValue = profile.config.topP!;
      }
      if (profile.config.topK != null) {
        isTopKEnabled = true;
        topKValue = profile.config.topK!;
      }
      if (profile.config.temperature != null) {
        isTemperatureEnabled = true;
        temperatureValue = profile.config.temperature!;
      }

      contextWindowValue = profile.config.contextWindow;
      conversationLengthValue = profile.config.conversationLength;
      maxTokensValue = profile.config.maxTokens;
      if (profile.config.customThinkingTokens != null) {
        isCustomThinkingTokensEnabled = true;
        customThinkingTokensValue = profile.config.customThinkingTokens!;
      }

      thinkingLevel = profile.config.thinkingLevel;
      profileConversations = profile.profileConversations;
      selectedMCPServerIds.addAll(profile.activeMCPServerIds);

      if (profile.persistChatSelection == null) {
        persistOverride = PersistOverride.off;
      } else {
        persistOverride = profile.persistChatSelection!
            ? PersistOverride.on
            : PersistOverride.disable;
      }
    }
    _loadMCPServers();
  }

  Future<void> _loadMCPServers() async {
    final mcpRepo = await MCPRepository.init();
    availableMCPServers = mcpRepo.getMCPServers();
    notifyListeners();
  }

  Future<void> saveAgent(
    AIProfile? existingProfile,
    BuildContext context,
  ) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tl('AI Profile Name'))));
      return;
    }

    final repository = await AIProfileRepository.init();
    final newProfile = AIProfile(
      id: existingProfile?.id ?? const Uuid().v4(),
      name: nameController.text,
      config: RequestConfig(
        systemPrompt: promptController.text,
        enableStream: enableStream,
        topP: isTopPEnabled ? topPValue : null,
        topK: isTopKEnabled ? topKValue : null,
        temperature: isTemperatureEnabled ? temperatureValue : null,
        contextWindow: contextWindowValue,
        conversationLength: conversationLengthValue,
        maxTokens: maxTokensValue,
        customThinkingTokens: isCustomThinkingTokensEnabled
            ? customThinkingTokensValue
            : null,
        thinkingLevel: thinkingLevel,
      ),
      profileConversations: profileConversations,
      activeMCPServers: selectedMCPServerIds
          .map((id) => ActiveMCPServer(id: id, activeToolIds: []))
          .toList(),
      persistChatSelection: persistOverride == PersistOverride.off
          ? null
          : (persistOverride == PersistOverride.on ? true : false),
    );

    if (existingProfile != null) {
      await repository.updateProfile(newProfile);
    } else {
      await repository.addProfile(newProfile);
    }
  }

  void toggleMCPServer(String serverId) {
    if (selectedMCPServerIds.contains(serverId)) {
      selectedMCPServerIds.remove(serverId);
    } else {
      selectedMCPServerIds.add(serverId);
    }
    notifyListeners();
  }

  void setPersistOverride(PersistOverride value) {
    persistOverride = value;
    notifyListeners();
  }

  void toggleStream(bool value) {
    enableStream = value;
    notifyListeners();
  }

  void toggleTopP(bool value) {
    isTopPEnabled = value;
    notifyListeners();
  }

  void setTopPValue(double value) {
    topPValue = value;
    notifyListeners();
  }

  void toggleTopK(bool value) {
    isTopKEnabled = value;
    notifyListeners();
  }

  void setTopKValue(double value) {
    topKValue = value;
    notifyListeners();
  }

  void toggleTemperature(bool value) {
    isTemperatureEnabled = value;
    notifyListeners();
  }

  void setTemperatureValue(double value) {
    temperatureValue = value;
    notifyListeners();
  }

  void setContextWindowValue(int value) {
    contextWindowValue = value;
  }

  void setConversationLengthValue(int value) {
    conversationLengthValue = value;
  }

  void setMaxTokensValue(int value) {
    maxTokensValue = value;
  }

  void toggleCustomThinkingTokens(bool value) {
    isCustomThinkingTokensEnabled = value;
    notifyListeners();
  }

  void setCustomThinkingTokensValue(int value) {
    customThinkingTokensValue = value;
    notifyListeners();
  }

  void setThinkingLevel(ThinkingLevel value) {
    thinkingLevel = value;
    notifyListeners();
  }

  void toggleProfileConversations(bool value) {
    profileConversations = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    promptController.dispose();
    super.dispose();
  }
}
