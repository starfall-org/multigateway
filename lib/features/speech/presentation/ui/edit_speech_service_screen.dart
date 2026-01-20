import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/features/speech/presentation/controllers/edit_speechservice_controller.dart';
import 'package:multigateway/features/speech/presentation/widgets/stt_configuration_section.dart';
import 'package:multigateway/features/speech/presentation/widgets/tts_configuration_section.dart';
import 'package:signals/signals_flutter.dart';

/// Màn hình chỉnh sửa speech service
class EditSpeechServiceScreen extends StatefulWidget {
  final SpeechService? service;

  const EditSpeechServiceScreen({super.key, this.service});

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
    _controller.initialize(widget.service);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.service == null
              ? tl('Add Speech Service')
              : tl('Edit Speech Service'),
        ),
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
                availableModels: _controller.availableModels.value,
                isLoadingModels: _controller.isLoadingModels.value,
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
                onModelChanged: (value) {
                  _controller.setModelId(value);
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
                availableModels: _controller.sttAvailableModels.value,
                isLoadingModels: _controller.isLoadingModels.value,
                onTypeChanged: (value) {
                  if (value != null) {
                    _controller.setSttType(value);
                  }
                },
                onProviderChanged: (value) {
                  _controller.setSttProvider(value);
                },
                onModelChanged: (value) {
                  _controller.setSttModelId(value);
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
