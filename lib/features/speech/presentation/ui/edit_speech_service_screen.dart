import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/speech/presentation/controllers/edit_speechservice_controller.dart';
import 'package:multigateway/features/speech/presentation/widgets/stt_configuration_section.dart';
import 'package:multigateway/features/speech/presentation/widgets/tts_configuration_section.dart';
import 'package:signals/signals_flutter.dart';

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
  late EditSpeechServiceController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = EditSpeechServiceController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    final success = await _controller.saveService(context);
    if (success && mounted) {
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
        child: Watch((context) {
          return TabBarView(
            controller: _tabController,
            children: [
              TtsConfigurationSection(
                nameController: _controller.nameController,
                selectedType: _controller.selectedType.value,
                availableProviders: _controller.availableProviders.value,
                selectedProviderId: _controller.selectedProviderId.value,
                useCustomVoice: _controller.useCustomVoice.value,
                customVoiceController: _controller.customVoiceController,
                selectedVoiceId: _controller.selectedVoiceId.value,
                availableVoices: _controller.availableVoices.value,
                isLoadingVoices: _controller.isLoadingVoices.value,
                modelNameController: _controller.modelNameController,
                selectedLanguage: _controller.selectedLanguage.value,
                availableLanguages: _controller.availableLanguages,
                speechRate: _controller.speechRate.value,
                volume: _controller.volume.value,
                pitch: _controller.pitch.value,
                onTypeChanged: (value) {
                  if (value != null) {
                    _controller.setServiceType(value);
                  }
                },
                onProviderChanged: (value) {
                  _controller.setProvider(value);
                },
                onToggleCustomVoice: () {
                  _controller.toggleCustomVoice();
                },
                onVoiceChanged: (value) {
                  _controller.setVoice(value);
                },
                onFetchVoices: () {
                  _controller.fetchVoices();
                },
                onLanguageChanged: (value) {
                  _controller.setLanguage(value);
                },
                onSpeechRateChanged: (value) {
                  _controller.setSpeechRate(value);
                },
                onVolumeChanged: (value) {
                  _controller.setVolume(value);
                },
                onPitchChanged: (value) {
                  _controller.setPitch(value);
                },
              ),
              SttConfigurationSection(
                selectedType: _controller.sttSelectedType.value,
                availableProviders: _controller.availableProviders.value,
                selectedProviderId: _controller.sttSelectedProviderId.value,
                modelNameController: _controller.sttModelNameController,
                onTypeChanged: (value) {
                  if (value != null) {
                    _controller.setSttType(value);
                  }
                },
                onProviderChanged: (value) {
                  _controller.setSttProvider(value);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
