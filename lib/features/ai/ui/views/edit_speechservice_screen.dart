import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/llm/data/provider_info_storage.dart';
import '../../../../core/speechservice/data/speechservice_store.dart';
import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../../../../core/speechservice/models/speechservice.dart';
import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/common_dropdown.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class AddTTSProfileScreen extends StatefulWidget {
  const AddTTSProfileScreen({super.key});

  @override
  State<AddTTSProfileScreen> createState() => _AddTTSProfileScreenState();
}

class _AddTTSProfileScreenState extends State<AddTTSProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  ServiceType _selectedType = ServiceType.system;

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _loadProviders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    final repository = await ProviderInfoStorage.init();
    final providers = repository.getProviders();
    setState(() {
      // Filter providers that have TTS capability
      _availableProviders = providers
          .where((p) => p.models.any((m) => m.output?.audio ?? false))
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
    if (_selectedType == ServiceType.system) {
      voices = ['en-US-x-sfg#male_1-local', 'en-US-x-sfg#female_1-local'];
    } else if (_selectedType == ServiceType.provider) {
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
      context.showInfoSnackBar(tl('Please enter a name'));
      return;
    }

    if (_selectedType == ServiceType.provider && _selectedProviderId == null) {
      context.showInfoSnackBar(tl('Please select a provider'));
      return;
    }

    final repository = await TTSRepository.init();

    if (_selectedType == ServiceType.provider) {}

    // Build TTS/STT objects according to current models
    final tts = TextToSpeech(
      id: const Uuid().v4(),
      icon: 'assets/brand_icons.json',
      name: _selectedType == ServiceType.system
          ? 'System TTS'
          : (_selectedProviderId ?? 'Provider TTS'),
      type: _selectedType,
      provider: _selectedType == ServiceType.provider
          ? _selectedProviderId
          : null,
      model: null,
      voiceId: _selectedVoiceId,
      settings: const {},
    );

    final stt = SpeechToText(
      id: const Uuid().v4(),
      icon: 'assets/brand_icons.json',
      name: 'System STT',
      type: ServiceType.system,
      provider: null,
      model: null,
      voiceId: null,
      settings: const {},
    );

    final profile = SpeechService(
      id: const Uuid().v4(),
      icon: 'assets/brand_icons.json', // Default icon path or logic
      name: _nameController.text,
      tts: tts,
      stt: stt,
    );

    await repository.addProfile(profile);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProfile,
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
        CustomTextField(controller: _nameController, label: tl('Profile Name')),
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
