import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/llm.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Section cấu hình thông tin provider
class ProviderInfoSection extends StatelessWidget {
  final AddProviderController controller;

  const ProviderInfoSection({
    super.key,
    required this.controller,
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
        CustomTextField(
          controller: controller.nameController,
          label: 'Name',
        ),
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

  String _getProviderIcon(ProviderType type, AddProviderController controller) {
    if (controller.vertexAI) return 'vertex-color';
    if (controller.azureAI) return 'azure-color';
    
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