import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/shared/utils/model_tools.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';

class EditProfileController {
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
  final availableMcpItems = signal<List<McpInfo>>([]);
  final selectedMcpItemIds = signal<List<String>>([]);
  final activeModelTools = signal<List<ModelTool>>([]);
  final availableProviders = signal<List<LlmProviderInfo>>([]);
  final availableModels = signal<Map<String, List<LlmModel>>>({});
  EffectCleanup? _autoSaveCleanup;
  String? _editingProfileId;

  // Initialize with optional existing profile
  void initialize(ChatProfile? profile) {
    if (profile != null) {
      nameController.text = profile.name;
      promptController.text = profile.config.systemPrompt;
      avatarController.text = profile.icon ?? '';
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

      selectedMcpItemIds.value = List.from(profile.activeMcpName);
      activeModelTools.value = List.from(profile.activeModelTools);
      _editingProfileId = profile.id;
    }

    _setupAutoSave();

    nameController.addListener(_debouncedSave);
    promptController.addListener(_debouncedSave);
    avatarController.addListener(_debouncedSave);

    _loadMcpClients();
    _loadProvidersAndModels();
  }

  void _setupAutoSave() {
    _autoSaveCleanup = effect(() {
      enableStream.value;
      isTopPEnabled.value;
      topPValue.value;
      isTopKEnabled.value;
      topKValue.value;
      isTemperatureEnabled.value;
      temperatureValue.value;
      contextWindowValue.value;
      conversationLengthValue.value;
      maxTokensValue.value;
      isCustomThinkingTokensEnabled.value;
      customThinkingTokensValue.value;
      thinkingLevel.value;
      selectedMcpItemIds.value;
      activeModelTools.value;

      _debouncedSave();
    });
  }

  void _debouncedSave() {
    saveAgent();
  }

  Future<void> _loadMcpClients() async {
    final mcpRepo = await McpInfoStorage.init();
    availableMcpItems.value = mcpRepo.getItems().cast<McpInfo>();
  }

  Future<void> _loadProvidersAndModels() async {
    final providerRepo = await LlmProviderInfoStorage.init();
    final modelsRepo = await LlmProviderModelsStorage.init();

    final providers = await providerRepo.getItemsAsync();
    availableProviders.value = providers;

    final modelsMap = <String, List<LlmModel>>{};
    final modelEntries = await modelsRepo.getItemsAsync();
    for (final entry in modelEntries) {
      modelsMap[entry.id] = entry.models.whereType<LlmModel>().toList();
    }

    for (final provider in providers) {
      modelsMap.putIfAbsent(provider.id, () => <LlmModel>[]);
    }

    availableModels.value = modelsMap;
  }

  Future<void> saveAgent([
    ChatProfile? existingProfile,
    BuildContext? context,
  ]) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final repository = await ChatProfileStorage.init();
    final newProfile = ChatProfile(
      id: _editingProfileId ??= const Uuid().v4(),
      name: name,
      icon: avatarController.text.isNotEmpty ? avatarController.text : null,
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
      activeMcp: selectedMcpItemIds.value
          .map((id) => ActiveMcp(id: id, activeToolNames: []))
          .toList(),
      activeModelTools: activeModelTools.value,
    );

    if (existingProfile != null) {
      await repository.saveItem(newProfile);
    } else {
      await repository.saveItem(newProfile);
    }
  }

  void toggleMcpItem(String serverId) {
    final currentList = List<String>.from(selectedMcpItemIds.value);
    if (currentList.contains(serverId)) {
      currentList.remove(serverId);
    } else {
      currentList.add(serverId);
    }
    selectedMcpItemIds.value = currentList;
  }

  bool isModelToolEnabled({
    required String providerId,
    required String modelId,
    required String toolName,
  }) {
    return activeModelTools.value.any(
      (tool) =>
          tool.providerId == providerId &&
          tool.modelId == modelId &&
          toolNameMatches(tool.toolName, toolName),
    );
  }

  void toggleModelTool({
    required String providerId,
    required String modelId,
    required String toolName,
    required bool enabled,
  }) {
    final current = List<ModelTool>.from(activeModelTools.value);
    final index = current.indexWhere(
      (tool) =>
          tool.providerId == providerId &&
          tool.modelId == modelId &&
          toolNameMatches(tool.toolName, toolName),
    );

    if (enabled) {
      if (index == -1) {
        current.add(
          ModelTool(
            providerId: providerId,
            modelId: modelId,
            toolName: toolName,
          ),
        );
      }
    } else if (index != -1) {
      current.removeAt(index);
    }

    activeModelTools.value = current;
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
    _autoSaveCleanup?.call();
    nameController.removeListener(_debouncedSave);
    promptController.removeListener(_debouncedSave);
    avatarController.removeListener(_debouncedSave);

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
    availableMcpItems.dispose();
    selectedMcpItemIds.dispose();
    activeModelTools.dispose();
    availableProviders.dispose();
    availableModels.dispose();
  }

  void pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarController.text = image.path;
    }
  }
}
