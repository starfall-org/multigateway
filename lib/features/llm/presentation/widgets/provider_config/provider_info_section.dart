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
  final AddProviderController controller;

  const ProviderInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedType = controller.selectedType.value;
      final responsesApi = controller.responsesApi.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CommonDropdown<ProviderType>(
            value: selectedType,
            labelText: tl('Compatibility'),
            options: ProviderType.values.map((type) {
              return DropdownOption<ProviderType>(
                value: type,
                label: type.name,
                icon: buildLogoIcon(
                  _getProviderIcon(type, controller),
                  size: 24,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateSelectedType(value);
              }
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(controller: controller.nameController, label: 'Name'),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.apiKeyController,
            label: 'API Key',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.baseUrlController,
            label: 'Base URL',
          ),
          const SizedBox(height: 8),
          if (selectedType == ProviderType.openai)
            CheckboxListTile(
              title: Text(tl('Responses API')),
              value: responsesApi,
              onChanged: (value) {
                if (value != null) {
                  controller.updateResponsesApi(value);
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ],
      );
    });
  }

  String _getProviderIcon(ProviderType type, AddProviderController controller) {
    switch (type) {
      case ProviderType.openai:
        return 'openai';
      case ProviderType.googleai:
        return 'aistudio';
      case ProviderType.anthropic:
        return 'anthropic';
      case ProviderType.ollama:
        return 'ollama';
    }
  }
}
