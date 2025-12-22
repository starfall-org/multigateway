import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/ai/ai_model.dart';
import '../../../core/models/provider.dart';
import '../../../core/storage/provider_repository.dart';
import '../../../core/storage/tts_repository.dart';
import '../../../core/models/speech_service.dart';
import '../../../shared/widgets/dropdown.dart';
import '../../../shared/widgets/custom_text_field.dart';

import '../../../core/translate.dart';

class AddTTSProfileScreen extends StatefulWidget {
  const AddTTSProfileScreen({super.key});

  @override
  State<AddTTSProfileScreen> createState() => _AddTTSProfileScreenState();
}

class _AddTTSProfileScreenState extends State<AddTTSProfileScreen> {
  final _nameController = TextEditingController();
  TTSServiceType _selectedType = TTSServiceType.system;

  // Provider TTS
  List<Provider> _availableProviders = [];
  String? _selectedProviderId;

  // ElevenLabs

  // Voice
  String? _selectedVoiceId;
  List<String> _availableVoices = [];
  bool _isLoadingVoices = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final repository = await ProviderRepository.init();
    final providers = repository.getProviders();
    setState(() {
      // Filter providers that have TTS capability
      _availableProviders = providers
          .where(
            (p) => p.models.any((m) => m.output.contains(ModelIOType.audio)),
          )
          .toList();
    });
  }

  Future<void> _fetchVoices() async {
    setState(() {
      _isLoadingVoices = true;
    });

    // Mock fetching voices
    await Future.delayed(const Duration(seconds: 1));

    List<String> voices = [];
    if (_selectedType == TTSServiceType.system) {
      voices = ['en-US-x-sfg#male_1-local', 'en-US-x-sfg#female_1-local'];
    } else if (_selectedType == TTSServiceType.provider) {
      voices = ['alloy', 'echo', 'fable', 'onyx', 'nova', 'shimmer'];
    }

    setState(() {
      _availableVoices = voices;
      _selectedVoiceId = voices.isNotEmpty ? voices.first : null;
      _isLoadingVoices = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tl('Please enter a name'))));
      return;
    }

    if (_selectedType == TTSServiceType.provider &&
        _selectedProviderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tl('Please select a provider'))));
      return;
    }

    final repository = await TTSRepository.init();

    Provider? selectedProvider;
    if (_selectedType == TTSServiceType.provider) {
      selectedProvider = _availableProviders.firstWhere(
        (p) => p.name == _selectedProviderId,
      );
    }

    final profile = SpeechService(
      id: const Uuid().v4(),
      icon: 'assets/brand_icons.json', // Default icon path or logic
      name: _nameController.text,
      type: _selectedType,
      provider: selectedProvider,
      voiceId: _selectedVoiceId,
    );

    await repository.addProfile(profile);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tl('Add TTS Profile')),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(controller: _nameController, label: tl('Profile Name')),
            const SizedBox(height: 16),
            CommonDropdown<TTSServiceType>(
              value: _selectedType,
              labelText: tl('Service Type'),
              options: TTSServiceType.values.map((type) {
                return DropdownOption<TTSServiceType>(
                  value: type,
                  label: type.name.toUpperCase(),
                  icon: Icon(
                    type == TTSServiceType.system ? Icons.settings : Icons.cloud,
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
            if (_selectedType == TTSServiceType.provider) ...[
              CommonDropdown<String>(
                value: _selectedProviderId,
                labelText: tl('Provider'),
                options: _availableProviders.map((p) {
                  final iconData = p.type == ProviderType.google
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
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
    
            Row(
              children: [
                Expanded(
                  child: _isLoadingVoices
                      ? const LinearProgressIndicator()
                      : CommonDropdown<String>(
                          value: _selectedVoiceId,
                          labelText: tl('Voice'),
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
        ),
      ),
    );
  }
}
