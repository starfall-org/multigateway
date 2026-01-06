import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

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

  // ElevenLabs

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
      // Get all providers - TTS capability will be determined by provider type
      _availableProviders = providers.toList();
    });
  }

  String _getSystemLocale() {
    try {
      final locale = Platform.localeName; // e.g., "en_US", "vi_VN"
      return locale.replaceAll('_', '-'); // Convert to "en-US", "vi-VN"
    } catch (e) {
      return 'en-US'; // Default fallback
    }
  }

  List<String> _getSystemVoices(String locale) {
    // Generate system voices based on locale
    // Format: locale#gender_number-local
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

    // Determine final voice ID
    String? finalVoiceId;
    if (_useCustomVoice && _customVoiceController.text.isNotEmpty) {
      finalVoiceId = _customVoiceController.text.trim();
    } else {
      finalVoiceId = _selectedVoiceId;
    }

    final repository = await SpeechServiceStorage.init();

    // Build TTS/STT objects according to current models
    final tts = TextToSpeech(
      type: _selectedType,
      provider: _selectedType == ServiceType.provider
          ? _selectedProviderId
          : null,
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
          tabs: [
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
          children: [_buildTTSTab(), _buildSTTTab()],
        ),
      ),
    );
  }

  Widget _buildTTSTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomTextField(controller: _nameController, label: tl('Service Name')),
        const SizedBox(height: 16),
        CommonDropdown<ServiceType>(
          value: _selectedType,
          labelText: tl('Service Type'),
          options: ServiceType.values.map((type) {
            return DropdownOption<ServiceType>(
              value: type,
              label: type.name.toUpperCase(),
              icon: Icon(
                type == ServiceType.system ? Icons.settings : Icons.cloud,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
                _selectedVoiceId = null;
                _availableVoices = [];
              });
            }
          },
        ),
        const SizedBox(height: 16),
        if (_selectedType == ServiceType.provider) ...[
          CommonDropdown<String>(
            value: _selectedProviderId,
            labelText: tl('Provider'),
            options: _availableProviders.map((p) {
              final iconData = p.type == ProviderType.googleai
                  ? Icons.cloud
                  : p.type == ProviderType.openai
                  ? Icons.api
                  : p.type == ProviderType.anthropic
                  ? Icons.psychology_alt
                  : Icons.memory;
              return DropdownOption<String>(
                value: p.name,
                label: p.name,
                icon: Icon(iconData),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProviderId = value;
                _selectedVoiceId = null;
                _availableVoices = [];
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Voice selection section
        Row(
          children: [
            Expanded(
              child: Text(
                tl('Voice'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _useCustomVoice = !_useCustomVoice;
                  if (_useCustomVoice) {
                    _customVoiceController.text = _selectedVoiceId ?? '';
                  }
                });
              },
              icon: Icon(_useCustomVoice ? Icons.list : Icons.edit),
              label: Text(_useCustomVoice ? tl('Use Preset') : tl('Custom')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_useCustomVoice) ...[
          CustomTextField(
            controller: _customVoiceController,
            label: tl('Custom Voice ID'),
            hint: tl('Enter voice ID manually'),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _isLoadingVoices
                    ? const LinearProgressIndicator()
                    : CommonDropdown<String>(
                        value: _selectedVoiceId,
                        labelText: tl('Select Voice'),
                        options: _availableVoices.map((voice) {
                          return DropdownOption<String>(
                            value: voice,
                            label: voice,
                            icon: const Icon(Icons.record_voice_over),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVoiceId = value;
                          });
                        },
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: tl('Fetch Voices'),
                onPressed: _fetchVoices,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSTTTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          tl('Speech to Text Configuration'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    tl('System Speech Recognition'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tl(
                  'Currently using system default speech recognition service.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
