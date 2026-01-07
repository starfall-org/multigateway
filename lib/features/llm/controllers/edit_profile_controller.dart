import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:uuid/uuid.dart';

class AddAgentViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController avatarController = TextEditingController();

  // State variables representing all fields of ChatProfile
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
  List<McpServer> availableMcpServers = [];
  final List<String> selectedMcpServerIds = [];

  // Initialize with optional existing profile
  void initialize(ChatProfile? profile) {
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
      selectedMcpServerIds.addAll(profile.activeMcpServerIds);
    }
    _loadMcpServers();
  }

  Future<void> _loadMcpServers() async {
    final mcpRepo = await McpServerInfoStorage.init();
    availableMcpServers = mcpRepo.getItems();
    notifyListeners();
  }

  Future<void> saveAgent(
    ChatProfile? existingProfile,
    BuildContext context,
  ) async {
    if (nameController.text.isEmpty) {
      context.showInfoSnackBar(tl('AI Profile Name'));
      return;
    }

    final repository = await ChatProfileStorage.init();
    final newProfile = ChatProfile(
      id: existingProfile?.id ?? const Uuid().v4(),
      name: nameController.text,
      config: LlmChatConfig(
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
      activeMcpServers: selectedMcpServerIds
          .map((id) => ActiveMcpServer(id: id, activeToolIds: []))
          .toList(),
    );

    if (existingProfile != null) {
      await repository.saveItem(newProfile);
    } else {
      await repository.saveItem(newProfile);
    }
  }

  void toggleMcpServer(String serverId) {
    if (selectedMcpServerIds.contains(serverId)) {
      selectedMcpServerIds.remove(serverId);
    } else {
      selectedMcpServerIds.add(serverId);
    }
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

  @override
  void dispose() {
    nameController.dispose();
    promptController.dispose();
    super.dispose();
  }

  void pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarController.text = image.path;
    }
  }
}
