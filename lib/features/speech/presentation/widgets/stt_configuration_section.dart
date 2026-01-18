import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Section cấu hình STT
class SttConfigurationSection extends StatelessWidget {
  final ServiceType selectedType;
  final List<LlmProviderInfo> availableProviders;
  final String? selectedProviderId;
  final TextEditingController modelNameController;
  final ValueChanged<ServiceType?> onTypeChanged;
  final ValueChanged<String?> onProviderChanged;

  const SttConfigurationSection({
    super.key,
    this.selectedType = ServiceType.system,
    this.availableProviders = const [],
    this.selectedProviderId,
    required this.modelNameController,
    required this.onTypeChanged,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        CommonDropdown<ServiceType>(
          value: selectedType,
          label: tl('Service Type'),
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
            label: tl('Provider'),
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
        ] else ...[
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
                    Icon(
                      Icons.mic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
      ],
    );
  }
}
