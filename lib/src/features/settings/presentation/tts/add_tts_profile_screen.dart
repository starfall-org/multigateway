import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lmhub/src/core/storage/provider_repository.dart';
import 'package:lmhub/src/core/storage/tts_repository.dart';
import 'package:lmhub/src/features/settings/domain/provider.dart';
import 'package:lmhub/src/features/settings/domain/tts_profile.dart';

class AddTTSProfileScreen extends StatefulWidget {
  const AddTTSProfileScreen({super.key});

  @override
  State<AddTTSProfileScreen> createState() => _AddTTSProfileScreenState();
}

class _AddTTSProfileScreenState extends State<AddTTSProfileScreen> {
  final _nameController = TextEditingController();
  TTSServiceType _selectedType = TTSServiceType.system;

  // Provider TTS
  List<LLMProvider> _availableProviders = [];
  String? _selectedProviderId;

  // ElevenLabs
  final _apiKeyController = TextEditingController();

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
            (p) => p.models.any(
              (m) => m.capabilities.contains(ModelCapability.tts),
            ),
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
    } else if (_selectedType == TTSServiceType.elevenLabs) {
      voices = ['Rachel', 'Drew', 'Clyde', 'Mimi'];
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
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    if (_selectedType == TTSServiceType.provider &&
        _selectedProviderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a provider')));
      return;
    }

    if (_selectedType == TTSServiceType.elevenLabs &&
        _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter API Key')));
      return;
    }

    final repository = await TTSRepository.init();

    final profile = TTSProfile(
      id: const Uuid().v4(),
      name: _nameController.text,
      type: _selectedType,
      providerId: _selectedProviderId,
      apiKey: _apiKeyController.text.isNotEmpty ? _apiKeyController.text : null,
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
        title: const Text('Add TTS Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Profile Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TTSServiceType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Service Type',
              border: OutlineInputBorder(),
            ),
            items: TTSServiceType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
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
            DropdownButtonFormField<String>(
              initialValue: _selectedProviderId,
              decoration: const InputDecoration(
                labelText: 'Provider',
                border: OutlineInputBorder(),
              ),
              items: _availableProviders.map((p) {
                return DropdownMenuItem(value: p.id, child: Text(p.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProviderId = value;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedType == TTSServiceType.elevenLabs) ...[
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _isLoadingVoices
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<String>(
                        initialValue: _selectedVoiceId,
                        decoration: const InputDecoration(
                          labelText: 'Voice',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableVoices.map((voice) {
                          return DropdownMenuItem(
                            value: voice,
                            child: Text(voice),
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
                tooltip: 'Fetch Voices',
                onPressed: _fetchVoices,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
