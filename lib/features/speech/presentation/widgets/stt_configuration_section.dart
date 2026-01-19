import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/core/speech/speech.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';

/// Section cấu hình STT
class SttConfigurationSection extends StatelessWidget {
  final ServiceType selectedType;
  final List<LlmProviderInfo> availableProviders;
  final String? selectedProviderId;
  final TextEditingController modelNameController;
  final List<LlmModel> availableModels;
  final bool isLoadingModels;
  final ValueChanged<ServiceType?> onTypeChanged;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<String?> onModelChanged;

  const SttConfigurationSection({
    super.key,
    this.selectedType = ServiceType.system,
    this.availableProviders = const [],
    this.selectedProviderId,
    required this.modelNameController,
    required this.availableModels,
    required this.isLoadingModels,
    required this.onTypeChanged,
    required this.onProviderChanged,
    required this.onModelChanged,
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
              return DropdownOption<String>(
                value: p.id,
                label: p.name,
                icon: p.icon != null && p.icon!.isNotEmpty
                    ? (p.icon!.endsWith('.json')
                          ? null
                          : Image.network(
                              p.icon!,
                              width: 20,
                              height: 20,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.cloud),
                            ))
                    : Icon(_getProviderIcon(p.type)),
              );
            }).toList(),
            onChanged: onProviderChanged,
          ),
          const SizedBox(height: 16),
          if (isLoadingModels)
            const LinearProgressIndicator()
          else
            CommonDropdown<String>(
              value: modelNameController.text.isNotEmpty
                  ? modelNameController.text
                  : null,
              label: tl('Model'),
              options: availableModels.map((m) {
                return DropdownOption<String>(
                  value: m.id,
                  label: m.displayName,
                  icon: const Icon(Icons.psychology),
                );
              }).toList(),
              onChanged: onModelChanged,
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

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.google:
        return Icons.cloud;
      case ProviderType.openai:
        return Icons.api;
      case ProviderType.anthropic:
        return Icons.psychology_alt;
      case ProviderType.ollama:
        return Icons.memory;
    }
  }
}
