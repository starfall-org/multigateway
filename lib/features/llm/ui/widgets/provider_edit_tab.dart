import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Widget tab chỉnh sửa thông tin provider
class ProviderEditTab extends StatelessWidget {
  final AddProviderController controller;
  final ValueChanged<ProviderType> onTypeChanged;

  const ProviderEditTab({
    super.key,
    required this.controller,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CommonDropdown<ProviderType>(
          value: controller.selectedType,
          labelText: tl('Compatibility'),
          options: ProviderType.values.map((type) {
            return DropdownOption<ProviderType>(
              value: type,
              label: type.name,
              icon: buildLogoIcon(
                controller.vertexAI
                    ? 'vertex-color'
                    : controller.azureAI
                    ? 'azure-color'
                    : type == ProviderType.openai
                    ? 'openai'
                    : type == ProviderType.googleai
                    ? 'aistudio'
                    : type == ProviderType.anthropic
                    ? 'anthropic'
                    : 'ollama',
                size: 24,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              controller.updateSelectedType(value);
              onTypeChanged(value);
            }
          },
        ),
        if (controller.selectedType == ProviderType.openai)
          CheckboxListTile(
            title: Text(tl('Azure AI')),
            value: controller.azureAI,
            onChanged: (value) {
              if (value != null) {
                controller.updateAzureAI(value);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        if (controller.selectedType == ProviderType.googleai)
          CheckboxListTile(
            title: Text(tl('Vertex AI')),
            value: controller.vertexAI,
            onChanged: (value) {
              if (value != null) {
                controller.updateVertexAI(value);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
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
        if (controller.selectedType == ProviderType.openai)
          CheckboxListTile(
            title: Text(tl('Responses API')),
            value: controller.responsesApi,
            onChanged: (value) {
              if (value != null) {
                controller.updateResponsesApi(value);
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
      ],
    );
  }
}
