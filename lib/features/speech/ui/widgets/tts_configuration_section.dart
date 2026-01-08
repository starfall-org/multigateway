import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Section cấu hình TTS
class TtsConfigurationSection extends StatelessWidget {
  final TextEditingController nameController;
  final ServiceType selectedType;
  final List<LlmProviderInfo> availableProviders;
  final String? selectedProviderId;
  final bool useCustomVoice;
  final TextEditingController customVoiceController;
  final String? selectedVoiceId;
  final List<String> availableVoices;
  final bool isLoadingVoices;
  final TextEditingController modelNameController;
  final String? selectedLanguage;
  final List<String> availableLanguages;
  final double speechRate;
  final double volume;
  final double pitch;
  final ValueChanged<ServiceType?> onTypeChanged;
  final ValueChanged<String?> onProviderChanged;
  final VoidCallback onToggleCustomVoice;
  final ValueChanged<String?> onVoiceChanged;
  final VoidCallback onFetchVoices;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<double> onSpeechRateChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onPitchChanged;

  const TtsConfigurationSection({
    super.key,
    required this.nameController,
    required this.selectedType,
    required this.availableProviders,
    required this.selectedProviderId,
    required this.useCustomVoice,
    required this.customVoiceController,
    required this.selectedVoiceId,
    required this.availableVoices,
    required this.isLoadingVoices,
    required this.modelNameController,
    required this.selectedLanguage,
    required this.availableLanguages,
    required this.speechRate,
    required this.volume,
    required this.pitch,
    required this.onTypeChanged,
    required this.onProviderChanged,
    required this.onToggleCustomVoice,
    required this.onVoiceChanged,
    required this.onFetchVoices,
    required this.onLanguageChanged,
    required this.onSpeechRateChanged,
    required this.onVolumeChanged,
    required this.onPitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CustomTextField(
          controller: nameController,
          label: tl('Service Name'),
        ),
        const SizedBox(height: 16),
        CommonDropdown<ServiceType>(
          value: selectedType,
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
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        if (selectedType == ServiceType.provider) ...[
          CommonDropdown<String>(
            value: selectedProviderId,
            labelText: tl('Provider'),
            options: availableProviders.map((p) {
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
            onChanged: onProviderChanged,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: modelNameController,
            label: tl('Model Name'),
            hint: tl('Enter model name (optional)'),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                tl('Voice'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: onToggleCustomVoice,
              icon: Icon(useCustomVoice ? Icons.list : Icons.edit),
              label: Text(useCustomVoice ? tl('Use Preset') : tl('Custom')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (useCustomVoice) ...[
          CustomTextField(
            controller: customVoiceController,
            label: tl('Custom Voice ID'),
            hint: tl('Enter voice ID manually'),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: isLoadingVoices
                    ? const LinearProgressIndicator()
                    : CommonDropdown<String>(
                        value: selectedVoiceId,
                        labelText: tl('Select Voice'),
                        options: availableVoices.map((voice) {
                          return DropdownOption<String>(
                            value: voice,
                            label: voice,
                            icon: const Icon(Icons.record_voice_over),
                          );
                        }).toList(),
                        onChanged: onVoiceChanged,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: tl('Fetch Voices'),
                onPressed: onFetchVoices,
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text(
          tl('Settings'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        // Language
        if (availableLanguages.isNotEmpty) ...[
          CommonDropdown<String>(
            value: selectedLanguage,
            labelText: tl('Language'),
            options: availableLanguages.map((lang) {
              return DropdownOption<String>(
                value: lang,
                label: lang,
                icon: const Icon(Icons.language),
              );
            }).toList(),
            onChanged: onLanguageChanged,
          ),
          const SizedBox(height: 16),
        ],
        // Speech Rate
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tl('Speech Rate')),
                Text('${speechRate.toStringAsFixed(1)}x'),
              ],
            ),
            Slider(
              value: speechRate,
              min: 0.25,
              max: 2.0,
              divisions: 7,
              onChanged: onSpeechRateChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Volume
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tl('Volume')),
                Text('${(volume * 100).toInt()}%'),
              ],
            ),
            Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: onVolumeChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Pitch
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tl('Pitch')),
                Text(pitch.toStringAsFixed(1)),
              ],
            ),
            Slider(
              value: pitch,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              onChanged: onPitchChanged,
            ),
          ],
        ),
      ],
    );
  }
}