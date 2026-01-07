import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/ui/widgets/stt_configuration_section.dart';
import 'package:multigateway/features/speech/ui/widgets/tts_configuration_section.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:uuid/uuid.dart';

/// Màn hình chỉnh sửa speech service
class EditSpeechServiceScreen extends StatefulWidget {
  const EditSpeechServiceScreen({super.key});

  @override
  State<EditSpeechServiceScreen> createState() =>
      _EditSpeechServiceScreenState();
}

class _EditSpeechServiceScreenState extends State<EditSpeechServiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  ServiceType _selectedType = ServiceType.system;

  // Provider TTS
  List<LlmProviderInfo> _availableProviders = [];
  String? _selectedProviderId;

  // Voice
  String? _selectedVoiceId;
  final _customVoiceController = TextEditingController();
  List<String> _availableVoices = [];
  bool _isLoadingVoices = false;
  bool _useCustomVoice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _loadProviders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _customVoiceController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    final repository = await LlmProviderInfoStorage.init();
    final providers = repository.getItems();
    setState(() {
      _availableProviders = providers.toList();
    });
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

  Future<void> _fetchVoices() async {
    setState(() {
      _isLoadingVoices = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    List<String> voices = [];

    if (_selectedType == ServiceType.system) {
      final locale = _getSystemLocale();
      voices = _getSystemVoices(locale);
    } else if (_selectedType == ServiceType.provider) {
      if (_selectedProviderId != null) {
        final provider = _availableProviders.firstWhere(
          (p) => p.name == _selectedProviderId,
          orElse: () => _availableProviders.first,
        );

        if (provider.type == ProviderType.openai) {
          voices = _getOpenAIVoices();
        }
      }
    }

    setState(() {
      _availableVoices = voices;
      _selectedVoiceId = voices.isNotEmpty ? voices.first : null;
      _isLoadingVoices = false;
    });
  }

  Future<void> _saveService() async {
    if (_nameController.text.isEmpty) {
      context.showInfoSnackBar(tl('Please enter a name'));
      return;
    }

    if (_selectedType == ServiceType.provider && _selectedProviderId == null) {
      context.showInfoSnackBar(tl('Please select a provider'));
      return;
    }

    String? finalVoiceId;
    if (_useCustomVoice && _customVoiceController.text.isNotEmpty) {
      finalVoiceId = _customVoiceController.text.trim();
    } else {
      finalVoiceId = _selectedVoiceId;
    }

    final repository = await SpeechServiceStorage.init();

    final tts = TextToSpeech(
      type: _selectedType,
      provider:
          _selectedType == ServiceType.provider ? _selectedProviderId : null,
      modelName: null,
      voiceId: finalVoiceId,
      settings: const {},
    );

    final stt = SpeechToText(
      type: ServiceType.system,
      provider: null,
      modelName: null,
      settings: const {},
    );

    final profile = SpeechService(
      id: const Uuid().v4(),
      name: _nameController.text,
      icon: 'assets/brand_icons.json',
      tts: tts,
      stt: stt,
    );

    await repository.saveItem(profile);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveService,
        label: Text(tl('Save')),
        icon: const Icon(Icons.save),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.record_voice_over), text: 'TTS'),
            Tab(icon: Icon(Icons.mic), text: 'STT'),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [
            TtsConfigurationSection(
              nameController: _nameController,
              selectedType: _selectedType,
              availableProviders: _availableProviders,
              selectedProviderId: _selectedProviderId,
              useCustomVoice: _useCustomVoice,
              customVoiceController: _customVoiceController,
              selectedVoiceId: _selectedVoiceId,
              availableVoices: _availableVoices,
              isLoadingVoices: _isLoadingVoices,
              onTypeChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _selectedVoiceId = null;
                    _availableVoices = [];
                  });
                }
              },
              onProviderChanged: (value) {
                setState(() {
                  _selectedProviderId = value;
                  _selectedVoiceId = null;
                  _availableVoices = [];
                });
              },
              onToggleCustomVoice: () {
                setState(() {
                  _useCustomVoice = !_useCustomVoice;
                  if (_useCustomVoice) {
                    _customVoiceController.text = _selectedVoiceId ?? '';
                  }
                });
              },
              onVoiceChanged: (value) {
                setState(() {
                  _selectedVoiceId = value;
                });
              },
              onFetchVoices: _fetchVoices,
            ),
            const SttConfigurationSection(),
          ],
        ),
      ),
    );
  }
}
