import 'package:flutter/material.dart';
import 'package:multigateway/app/models/default_options.dart';
import 'package:multigateway/app/storage/default_options_storage.dart';
import 'package:multigateway/core/profile/models/chat_profile.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:signals/signals.dart';

/// Controller quản lý state và lưu trữ cho Default Options page
class DefaultOptionsController {
  final chatProviderController = TextEditingController();
  final chatModelController = TextEditingController();
  final translationProviderController = TextEditingController();
  final translationModelController = TextEditingController();

  final isLoading = signal<bool>(true);
  final isSaving = signal<bool>(false);
  final profiles = signal<List<ChatProfile>>([]);
  final selectedProfileId = signal<String?>(null);

  Future<void> initialize() async {
    final defaultsStorage = await DefaultOptionsStorage.instance;
    final profilesStorage = await ChatProfileStorage.instance;

    final defaults = defaultsStorage.currentModels;
    final profileList = profilesStorage.getItems();
    profiles.value = profileList;

    final chatModel = defaults.defaultModels.chatModel;
    final translationModel = defaults.defaultModels.translationModel;

    _setControllers(chatModel, chatProviderController, chatModelController);
    _setControllers(
      translationModel,
      translationProviderController,
      translationModelController,
    );

    final profileIds = profileList.map((p) => p.id).toSet();
    selectedProfileId.value =
        (defaults.defaultProfileId.isNotEmpty && profileIds.contains(defaults.defaultProfileId))
            ? defaults.defaultProfileId
            : null;

    isLoading.value = false;
  }

  Future<String?> saveDefaults() async {
    final validationError = _validateForm();
    if (validationError != null) return validationError;

    isSaving.value = true;
    try {
      final defaultsStorage = await DefaultOptionsStorage.instance;
      final existing = defaultsStorage.currentModels;

      final chatModel = _modelFromControllers(
        chatProviderController,
        chatModelController,
      );
      final translationModel = _modelFromControllers(
        translationProviderController,
        translationModelController,
      );

      final updated = DefaultOptions(
        defaultModels: _buildUpdatedModels(
          existing.defaultModels,
          chatModel,
          translationModel,
        ),
        defaultProfileId: selectedProfileId.value ?? '',
      );

      await defaultsStorage.updateModels(updated);
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> resetDefaults() async {
    isSaving.value = true;
    try {
      final defaultsStorage = await DefaultOptionsStorage.instance;
      await defaultsStorage.updateModels(
        DefaultOptions(
          defaultModels: DefaultModels(),
          defaultProfileId: '',
        ),
      );
      chatProviderController.clear();
      chatModelController.clear();
      translationProviderController.clear();
      translationModelController.clear();
      selectedProfileId.value = null;
    } finally {
      isSaving.value = false;
    }
  }

  void updateSelectedProfile(String? profileId) {
    selectedProfileId.value =
        (profileId == null || profileId.isEmpty) ? null : profileId;
  }

  DefaultModels _buildUpdatedModels(
    DefaultModels existing,
    DefaultModel? chatModel,
    DefaultModel? translationModel,
  ) {
    return DefaultModels(
      titleGenerationModel: existing.titleGenerationModel,
      chatSummarizationModel: existing.chatSummarizationModel,
      translationModel: translationModel,
      supportOcrModel: existing.supportOcrModel,
      embeddingModel: existing.embeddingModel,
      imageGenerationModel: existing.imageGenerationModel,
      chatModel: chatModel,
      audioGenerationModel: existing.audioGenerationModel,
      videoGenerationModel: existing.videoGenerationModel,
      rerankModel: existing.rerankModel,
    );
  }

  DefaultModel? _modelFromControllers(
    TextEditingController provider,
    TextEditingController model,
  ) {
    final providerText = provider.text.trim();
    final modelText = model.text.trim();
    if (providerText.isEmpty && modelText.isEmpty) return null;
    return DefaultModel(modelId: modelText, providerId: providerText);
  }

  String? _validateForm() {
    final chatProvider = chatProviderController.text.trim();
    final chatModel = chatModelController.text.trim();
    final translationProvider = translationProviderController.text.trim();
    final translationModel = translationModelController.text.trim();

    final chatFieldsValid =
        (chatProvider.isEmpty && chatModel.isEmpty) ||
            (chatProvider.isNotEmpty && chatModel.isNotEmpty);
    if (!chatFieldsValid) {
      return 'Please fill both chat provider and chat model, or leave both empty.';
    }

    final translationFieldsValid =
        (translationProvider.isEmpty && translationModel.isEmpty) ||
            (translationProvider.isNotEmpty && translationModel.isNotEmpty);
    if (!translationFieldsValid) {
      return 'Please fill both translation provider and translation model, or leave both empty.';
    }

    return null;
  }

  void _setControllers(
    DefaultModel? model,
    TextEditingController providerController,
    TextEditingController modelController,
  ) {
    providerController.text = model?.providerId ?? '';
    modelController.text = model?.modelId ?? '';
  }

  void dispose() {
    chatProviderController.dispose();
    chatModelController.dispose();
    translationProviderController.dispose();
    translationModelController.dispose();
    isLoading.dispose();
    isSaving.dispose();
    profiles.dispose();
    selectedProfileId.dispose();
  }
}
