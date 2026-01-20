import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Section cấu hình thông tin provider
class ProviderInfoSection extends StatelessWidget {
  final EditProviderController controller;

  const ProviderInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedType = controller.selectedType.value;
      final responsesApi = controller.responsesApi.value;
      final supportStream = controller.supportStream.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CommonDropdown<ProviderType>(
            value: selectedType,
            label: tl('Compatibility'),
            options: ProviderType.values.map((type) {
              return DropdownOption<ProviderType>(
                value: type,
                label: type.name,
                icon: buildLogoIcon(_getProviderIcon(type), size: 24),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateSelectedType(value);
              }
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(signal: controller.name, label: 'Name'),
          const SizedBox(height: 16),
          CustomTextField(
            signal: controller.apiKey,
            label: 'API Key',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(signal: controller.baseUrl, label: 'Base URL'),
          const SizedBox(height: 16),
          SwitchTile(
            title: tl('Responses API'),
            subtitle: tl('Use OpenAI Responses API format'),
            value: responsesApi,
            onChanged: (v) => controller.responsesApi.value = v,
            icon: Icons.api,
          ),
          const SizedBox(height: 12),
          SwitchTile(
            title: tl('Stream Support'),
            subtitle: tl('Enable streaming responses'),
            value: supportStream,
            onChanged: (v) => controller.supportStream.value = v,
            icon: Icons.stream,
          ),
        ],
      );
    });
  }

  String _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.openai:
        return 'openai';
      case ProviderType.google:
        return 'aistudio';
      case ProviderType.anthropic:
        return 'anthropic';
      case ProviderType.ollama:
        return 'ollama';
    }
  }
}

class SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const SwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: colorScheme.primary),
      ),
    );
  }
}
