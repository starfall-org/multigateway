import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Section cấu hình HTTP (LlmProviderConfig)
class HttpConfigSection extends StatelessWidget {
  final AddProviderController controller;

  const HttpConfigSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (controller.selectedType.name == 'openai' &&
            controller.responsesApi == false)
          ExpansionTile(
            title: Text(tl('Custom Routes')),
            subtitle: Text(controller.selectedType.name),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CustomTextField(
                      controller:
                          controller.openAIChatCompletionsRouteController,
                      label: 'Chat Completions Path',
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller:
                          controller.openLegacyAiModelsRouteOrUrlController,
                      label: 'List Models Path or URL',
                    ),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tl('Headers'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: controller.addHeader,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controller.headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(controller: header.key, label: 'Key'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: header.value,
                    label: 'Value',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => controller.removeHeader(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
