import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcp/mcp.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';

class AddAgentController {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController avatarController = TextEditingController();

  // State variables representing all fields of ChatProfile
  final enableStream = signal<bool>(true);
  final isTopPEnabled = signal<bool>(false);
  final topPValue = signal<double>(1.0);
  final isTopKEnabled = signal<bool>(false);
  final topKValue = signal<double>(40.0);
  final isTemperatureEnabled = signal<bool>(false);
  final temperatureValue = signal<double>(0.7);
  final contextWindowValue = signal<int>(60000);
  final conversationLengthValue = signal<int>(10);
  final maxTokensValue = signal<int>(4000);
  final isCustomThinkingTokensEnabled = signal<bool>(false);
  final customThinkingTokensValue = signal<int>(0);
  final thinkingLevel = signal<ThinkingLevel>(ThinkingLevel.auto);
  final availableMcpServers = signal<List<McpServer>>([]);
  final selectedMcpServerIds = signal<List<String>>([]);

  // Initialize with optional existing profile
  void initialize(ChatProfile? profile) {
    if (profile != null) {
      nameController.text = profile.name;
      promptController.text = profile.config.systemPrompt;
      enableStream.value = profile.config.enableStream;

      if (profile.config.topP != null) {
        isTopPEnabled.value = true;
        topPValue.value = profile.config.topP!;
      }
      if (profile.config.topK != null) {
        isTopKEnabled.value = true;
        topKValue.value = profile.config.topK!;
      }
      if (profile.config.temperature != null) {
        isTemperatureEnabled.value = true;
        temperatureValue.value = profile.config.temperature!;
      }

      contextWindowValue.value = profile.config.contextWindow;
      conversationLengthValue.value = profile.config.conversationLength;
      maxTokensValue.value = profile.config.maxTokens;
      if (profile.config.customThinkingTokens != null) {
        isCustomThinkingTokensEnabled.value = true;
        customThinkingTokensValue.value = profile.config.customThinkingTokens!;
      }

      thinkingLevel.value = profile.config.thinkingLevel;
      selectedMcpServerIds.value = List.from(profile.activeMcpServerIds);
    }
    _loadMcpServers();
  }

  Future<void> _loadMcpServers() async {
    final mcpRepo = await McpServerInfoStorage.init();
    availableMcpServers.value = mcpRepo.getItems().cast<McpServer>();
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
        enableStream: enableStream.value,
        topP: isTopPEnabled.value ? topPValue.value : null,
        topK: isTopKEnabled.value ? topKValue.value : null,
        temperature: isTemperatureEnabled.value ? temperatureValue.value : null,
        contextWindow: contextWindowValue.value,
        conversationLength: conversationLengthValue.value,
        maxTokens: maxTokensValue.value,
        customThinkingTokens: isCustomThinkingTokensEnabled.value
            ? customThinkingTokensValue.value
            : null,
        thinkingLevel: thinkingLevel.value,
      ),
      activeMcpServers: selectedMcpServerIds.value
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
    final currentList = List<String>.from(selectedMcpServerIds.value);
    if (currentList.contains(serverId)) {
      currentList.remove(serverId);
    } else {
      currentList.add(serverId);
    }
    selectedMcpServerIds.value = currentList;
  }

  void toggleStream(bool value) {
    enableStream.value = value;
  }

  void toggleTopP(bool value) {
    isTopPEnabled.value = value;
  }

  void setTopPValue(double value) {
    topPValue.value = value;
  }

  void toggleTopK(bool value) {
    isTopKEnabled.value = value;
  }

  void setTopKValue(double value) {
    topKValue.value = value;
  }

  void toggleTemperature(bool value) {
    isTemperatureEnabled.value = value;
  }

  void setTemperatureValue(double value) {
    temperatureValue.value = value;
  }

  void setContextWindowValue(int value) {
    contextWindowValue.value = value;
  }

  void setConversationLengthValue(int value) {
    conversationLengthValue.value = value;
  }

  void setMaxTokensValue(int value) {
    maxTokensValue.value = value;
  }

  void toggleCustomThinkingTokens(bool value) {
    isCustomThinkingTokensEnabled.value = value;
  }

  void setCustomThinkingTokensValue(int value) {
    customThinkingTokensValue.value = value;
  }

  void setThinkingLevel(ThinkingLevel value) {
    thinkingLevel.value = value;
  }

  void dispose() {
    nameController.dispose();
    promptController.dispose();
    avatarController.dispose();
    enableStream.dispose();
    isTopPEnabled.dispose();
    topPValue.dispose();
    isTopKEnabled.dispose();
    topKValue.dispose();
    isTemperatureEnabled.dispose();
    temperatureValue.dispose();
    contextWindowValue.dispose();
    conversationLengthValue.dispose();
    maxTokensValue.dispose();
    isCustomThinkingTokensEnabled.dispose();
    customThinkingTokensValue.dispose();
    thinkingLevel.dispose();
    availableMcpServers.dispose();
    selectedMcpServerIds.dispose();
  }

  void pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarController.text = image.path;
    }
  }
}
