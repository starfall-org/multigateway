import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/profiles/presentation/controllers/edit_profile_controller.dart';
import 'package:multigateway/features/profiles/presentation/widgets/profile_controller_provider.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:multigateway/shared/utils/model_tools.dart';
import 'package:signals/signals_flutter.dart';

/// Tab công cụ (MCP servers) của profile
class ProfileToolsTab extends StatelessWidget {
  const ProfileToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileControllerProvider.of(context);

    return Watch((context) {
      final providers = controller.availableProviders.value;
      final modelsByProvider = controller.availableModels.value;

      final modelToolSections = <Widget>[];
      for (final provider in providers) {
        final toolOptions = modelToolsForProvider(provider);
        if (toolOptions.isEmpty) continue;
        final models = modelsByProvider[provider.id] ?? const <LlmModel>[];
        modelToolSections.add(
          _ModelToolProviderSection(
            provider: provider,
            models: models,
            toolOptions: toolOptions,
            controller: controller,
          ),
        );
        modelToolSections.add(const SizedBox(height: 16));
      }
      if (modelToolSections.isNotEmpty) {
        modelToolSections.removeLast();
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tl('Model Tools'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (modelToolSections.isNotEmpty)
                ...modelToolSections
              else
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(tl('No model tools available')),
                ),
              const SizedBox(height: 24),
              if (controller.availableMcpItems.value.isNotEmpty) ...[
                Text(
                  tl('MCP Servers'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SettingsCard(
                  child: Column(
                    children: controller.availableMcpItems.value.map((mcp) {
                      return CheckboxListTile(
                        title: Text(mcp.name),
                        value: controller.selectedMcpItemIds.value.contains(
                          mcp.id,
                        ),
                        onChanged: (bool? value) {
                          controller.toggleMcpItem(mcp.id);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Text(tl('No MCP servers available')),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _ModelToolProviderSection extends StatelessWidget {
  final LlmProviderInfo provider;
  final List<LlmModel> models;
  final List<ModelToolOption> toolOptions;
  final EditProfileController controller;

  const _ModelToolProviderSection({
    required this.provider,
    required this.models,
    required this.toolOptions,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (models.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(tl('No models available')),
          )
        else
          ...models.map((model) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SettingsCard(
                child: ExpansionTile(
                  title: Text(model.displayName),
                  subtitle: Text(model.id),
                  children: toolOptions.map((option) {
                    final enabled = controller.isModelToolEnabled(
                      providerId: provider.id,
                      modelId: model.id,
                      toolName: option.name,
                    );
                    return SwitchListTile(
                      title: Text(tl(option.title)),
                      subtitle: Text(tl(option.description)),
                      value: enabled,
                      onChanged: (value) => controller.toggleModelTool(
                        providerId: provider.id,
                        modelId: model.id,
                        toolName: option.name,
                        enabled: value,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
      ],
    );
  }
}
