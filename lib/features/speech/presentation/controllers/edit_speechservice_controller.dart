import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';

/// Controller cho màn hình chỉnh sửa speech service
class EditSpeechServiceController {
  // Text controllers
  final nameController = TextEditingController();
  final customVoiceController = TextEditingController();
  final modelNameController = TextEditingController();
  final sttModelNameController = TextEditingController();

  // TTS State
  final selectedType = signal<ServiceType>(ServiceType.system);
  final availableProviders = signal<List<LlmProviderInfo>>([]);
  final selectedProviderId = signal<String?>(null);
  final selectedVoiceId = signal<String?>(null);
  final availableVoices = signal<List<String>>([]);
  final isLoadingVoices = signal<bool>(false);
  final useCustomVoice = signal<bool>(false);
  final selectedLanguage = signal<String?>(null);
  final speechRate = signal<double>(1.0);
  final volume = signal<double>(1.0);
  final pitch = signal<double>(1.0);

  // STT State
  final sttSelectedType = signal<ServiceType>(ServiceType.system);
  final sttSelectedProviderId = signal<String?>(null);
  final sttSelectedModelId = signal<String?>(null);

  // Models cache
  final availableModels = signal<List<LlmModel>>([]);
  final sttAvailableModels = signal<List<LlmModel>>([]);
  final isLoadingModels = signal<bool>(false);
  EffectCleanup? _autoSaveCleanup;
  String? _editingServiceId;

  // Available languages
  final List<String> availableLanguages = [
    'en-US',
    'vi-VN',
    'zh-CN',
    'ja-JP',
    'ko-KR',
    'de-DE',
    'fr-FR',
    'es-ES',
  ];

  EditSpeechServiceController();

  Future<void> initialize(SpeechService? service) async {
    await _loadProviders();

    if (service != null) {
      _editingServiceId = service.id;
      nameController.text = service.name;

      // Restore TTS Settings
      selectedType.value = service.tts.type;

      if (service.tts.type == ServiceType.provider) {
        selectedProviderId.value = service.tts.provider;
        // Wait for models to load if needed?
        // Logic suggests we load models when provider is set.
        if (service.tts.provider != null) {
          await _loadModels(service.tts.provider!, true);
        }
      }

      if (service.tts.modelId != null) {
        modelNameController.text = service.tts.modelId!;
      }

      if (service.tts.voiceId != null) {
        // Simple heuristic: if it's not a standard voice, it might be custom
        // But better to check against value.
        // For simplicity, we just set the value.
        // If it's custom, user will see it in text field if they toggle custom.
        selectedVoiceId.value = service.tts.voiceId;
        customVoiceController.text = service.tts.voiceId!;
      }

      final settings = service.tts.settings;
      selectedLanguage.value = settings['language'] as String?;
      speechRate.value = (settings['speechRate'] as num?)?.toDouble() ?? 1.0;
      volume.value = (settings['volume'] as num?)?.toDouble() ?? 1.0;
      pitch.value = (settings['pitch'] as num?)?.toDouble() ?? 1.0;

      // Restore STT Settings
      sttSelectedType.value = service.stt.type;
      if (service.stt.type == ServiceType.provider) {
        sttSelectedProviderId.value = service.stt.provider;
        if (service.stt.provider != null) {
          await _loadModels(service.stt.provider!, false);
        }
      }

      if (service.stt.modelId != null) {
        sttModelNameController.text = service.stt.modelId!;
      }
    } else {
      selectedLanguage.value = _getSystemLocale();
    }

    // Listen to text changes
    nameController.addListener(_debouncedSave);
    customVoiceController.addListener(_debouncedSave);
    modelNameController.addListener(_debouncedSave);
    sttModelNameController.addListener(_debouncedSave);

    _setupAutoSave();
  }

  void _setupAutoSave() {
    _autoSaveCleanup = effect(() {
      selectedType.value;
      selectedProviderId.value;
      selectedVoiceId.value;
      useCustomVoice.value;
      selectedLanguage.value;
      speechRate.value;
      volume.value;
      pitch.value;
      sttSelectedType.value;
      sttSelectedProviderId.value;
      sttSelectedModelId.value;

      _debouncedSave();
    });
  }

  void _debouncedSave() {
    saveService();
  }

  Future<void> _loadProviders() async {
    final repository = await LlmProviderInfoStorage.init();
    final providers = repository.getItems();
    availableProviders.value = providers.toList();
  }

  String _getSystemLocale() {
    try {
      final locale = Platform.localeName;
      return locale.replaceAll('_', '-');
    } catch (e) {
      return 'en-US';
    }
  }

  List<String> _getSystemVoices(String locale) {
    return [
      '$locale#male_1-local',
      '$locale#male_2-local',
      '$locale#female_1-local',
      '$locale#female_2-local',
    ];
  }

  List<String> _getOpenAIVoices() {
    return ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];
  }

  Future<void> fetchVoices() async {
    isLoadingVoices.value = true;

    await Future.delayed(const Duration(milliseconds: 300));

    List<String> voices = [];

    if (selectedType.value == ServiceType.system) {
      final locale = _getSystemLocale();
      voices = _getSystemVoices(locale);
    } else if (selectedType.value == ServiceType.provider) {
      if (selectedProviderId.value != null) {
        final provider = availableProviders.value.firstWhere(
          (p) => p.name == selectedProviderId.value,
          orElse: () => availableProviders.value.first,
        );

        if (provider.type == ProviderType.openai) {
          voices = _getOpenAIVoices();
        }
      }
    }

    availableVoices.value = voices;
    selectedVoiceId.value = voices.isNotEmpty ? voices.first : null;
    isLoadingVoices.value = false;
  }

  Future<void> _loadModels(String providerId, bool isTts) async {
    isLoadingModels.value = true;
    try {
      final modelsStorage = await LlmProviderModelsStorage.instance;
      final providerModels = modelsStorage.getItem(providerId);
      if (providerModels != null) {
        final filteredModels = providerModels.models
            .whereType<LlmModel>()
            .where((m) {
              if (isTts) {
                return m.outputCapabilities.audio == true;
              } else {
                return m.inputCapabilities.audio == true;
              }
            })
            .toList();

        if (isTts) {
          availableModels.value = filteredModels;
          if (modelNameController.text.isEmpty && filteredModels.isNotEmpty) {
            modelNameController.text = filteredModels.first.id;
          }
        } else {
          sttAvailableModels.value = filteredModels;
          if (sttModelNameController.text.isEmpty &&
              filteredModels.isNotEmpty) {
            sttModelNameController.text = filteredModels.first.id;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading models: $e');
    } finally {
      isLoadingModels.value = false;
    }
  }

  void setServiceType(ServiceType type) {
    selectedType.value = type;
    selectedVoiceId.value = null;
    availableVoices.value = [];
    if (type == ServiceType.provider && selectedProviderId.value != null) {
      _loadModels(selectedProviderId.value!, true);
    }
  }

  void setProvider(String? providerId) {
    selectedProviderId.value = providerId;
    selectedVoiceId.value = null;
    availableVoices.value = [];
    if (providerId != null) {
      _loadModels(providerId, true);
    }
  }

  void toggleCustomVoice() {
    useCustomVoice.value = !useCustomVoice.value;
    if (useCustomVoice.value) {
      customVoiceController.text = selectedVoiceId.value ?? '';
    }
  }

  void setVoice(String? voiceId) {
    selectedVoiceId.value = voiceId;
  }

  void setLanguage(String? language) {
    selectedLanguage.value = language;
  }

  void setSpeechRate(double rate) {
    speechRate.value = rate;
  }

  void setVolume(double vol) {
    volume.value = vol;
  }

  void setPitch(double p) {
    pitch.value = p;
  }

  void setSttType(ServiceType type) {
    sttSelectedType.value = type;
    if (type == ServiceType.provider && sttSelectedProviderId.value != null) {
      _loadModels(sttSelectedProviderId.value!, false);
    }
  }

  void setSttProvider(String? providerId) {
    sttSelectedProviderId.value = providerId;
    if (providerId != null) {
      _loadModels(providerId, false);
    }
  }

  void setModelId(String? modelId) {
    if (modelId != null) {
      modelNameController.text = modelId;
    }
  }

  void setSttModelId(String? modelId) {
    if (modelId != null) {
      sttModelNameController.text = modelId;
    }
  }

  Future<bool> saveService([BuildContext? context]) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return false;

    if (selectedType.value == ServiceType.provider &&
        selectedProviderId.value == null) {
      if (context != null) {
        context.showInfoSnackBar(tl('Please select a provider'));
      }
      return false;
    }

    String? finalVoiceId;
    if (useCustomVoice.value && customVoiceController.text.isNotEmpty) {
      finalVoiceId = customVoiceController.text.trim();
    } else {
      finalVoiceId = selectedVoiceId.value;
    }

    // Validate voice selection
    if (finalVoiceId == null || finalVoiceId.isEmpty) {
      if (context != null) {
        context.showInfoSnackBar(tl('Please select or enter a voice'));
      }
      return false;
    }

    final repository = await SpeechServiceStorage.init();

    final tts = TextToSpeech(
      type: selectedType.value,
      provider: selectedType.value == ServiceType.provider
          ? selectedProviderId.value
          : null,
      modelId: modelNameController.text.isNotEmpty
          ? modelNameController.text
          : null,
      voiceId: finalVoiceId,
      settings: {
        'language': selectedLanguage.value ?? _getSystemLocale(),
        'speechRate': speechRate.value,
        'volume': volume.value,
        'pitch': pitch.value,
      },
    );

    final stt = SpeechToText(
      type: sttSelectedType.value,
      provider: sttSelectedType.value == ServiceType.provider
          ? sttSelectedProviderId.value
          : null,
      modelId: sttModelNameController.text.isNotEmpty
          ? sttModelNameController.text
          : null,
      settings: const {},
    );

    final profile = SpeechService(
      id: _editingServiceId ??= const Uuid().v4(),
      name: name,
      icon: 'assets/brand_icons.json',
      tts: tts,
      stt: stt,
    );

    await repository.saveItem(profile);
    return true;
  }

  void dispose() {
    _autoSaveCleanup?.call();
    nameController.removeListener(_debouncedSave);
    customVoiceController.removeListener(_debouncedSave);
    modelNameController.removeListener(_debouncedSave);
    sttModelNameController.removeListener(_debouncedSave);

    nameController.dispose();
    customVoiceController.dispose();
    modelNameController.dispose();
    sttModelNameController.dispose();
    selectedType.dispose();
    availableProviders.dispose();
    selectedProviderId.dispose();
    selectedVoiceId.dispose();
    availableVoices.dispose();
    isLoadingVoices.dispose();
    useCustomVoice.dispose();
    selectedLanguage.dispose();
    speechRate.dispose();
    volume.dispose();
    pitch.dispose();
    sttSelectedType.dispose();
    sttSelectedProviderId.dispose();
    sttSelectedModelId.dispose();
    availableModels.dispose();
    sttAvailableModels.dispose();
    isLoadingModels.dispose();
  }
}
