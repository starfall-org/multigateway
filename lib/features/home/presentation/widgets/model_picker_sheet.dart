import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ModelPickerSheet extends StatelessWidget {
  final ReadonlySignal<List<LlmProviderInfo>> providers;
  final ReadonlySignal<Map<String, List<LlmModel>>> providerModels;
  final ReadonlySignal<Map<String, bool>> providerCollapsed;
  final ReadonlySignal<String?> selectedProviderName;
  final ReadonlySignal<String?> selectedModelName;
  final Function(String providerName, bool collapsed) onToggleProvider;
  final Function(String providerName, String modelName) onSelectModel;
  final ScrollController scrollController;

  const ModelPickerSheet({
    super.key,
    required this.providers,
    required this.providerModels,
    required this.providerCollapsed,
    required this.selectedProviderName,
    required this.selectedModelName,
    required this.onToggleProvider,
    required this.onSelectModel,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final providersList = providers.value;
      final providerModelsMap = providerModels.value;
      final collapsedMap = providerCollapsed.value;
      final currentSelectedProvider = selectedProviderName.value;
      final currentSelectedModel = selectedModelName.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Text(
              tl('Select Model'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: providersList.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(tl('No providers configured')),
                      ),
                    ]
                  : providersList.map((provider) {
                      final collapsed = collapsedMap[provider.name] ?? false;
                      final models = providerModelsMap[provider.id] ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _ProviderIcon(name: provider.name),
                            ),
                            title: Text(provider.name),
                            trailing: Icon(
                              collapsed ? Icons.expand_more : Icons.expand_less,
                            ),
                            onTap: () =>
                                onToggleProvider(provider.name, !collapsed),
                          ),
                          if (!collapsed)
                            ...models.map((model) {
                              final isSelected =
                                  currentSelectedProvider == provider.name &&
                                  currentSelectedModel == model.id;
                              return ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 56,
                                  right: 16,
                                  top: 4,
                                  bottom: 4,
                                ),
                                title: Text(model.id),
                                leading: _ModelIcon(model: model),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : null,
                                onTap: () {
                                  onSelectModel(provider.name, model.id);
                                  Navigator.pop(context);
                                },
                              );
                            }),
                        ],
                      );
                    }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required ReadonlySignal<List<LlmProviderInfo>> providers,
    required ReadonlySignal<Map<String, List<LlmModel>>> providerModels,
    required ReadonlySignal<Map<String, bool>> providerCollapsed,
    required ReadonlySignal<String?> selectedProviderName,
    required ReadonlySignal<String?> selectedModelName,
    required Function(String providerName, bool collapsed) onToggleProvider,
    required Function(String providerName, String modelName) onSelectModel,
  }) {
    CustomBottomSheet.show(
      context,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      builder: (ctx, scrollController) => ModelPickerSheet(
        providers: providers,
        providerModels: providerModels,
        providerCollapsed: providerCollapsed,
        selectedProviderName: selectedProviderName,
        selectedModelName: selectedModelName,
        onToggleProvider: onToggleProvider,
        onSelectModel: onSelectModel,
        scrollController: scrollController,
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  final String name;
  const _ProviderIcon({required this.name});

  @override
  Widget build(BuildContext context) {
    return buildIcon(name);
  }
}

class _ModelIcon extends StatelessWidget {
  final LlmModel model;
  const _ModelIcon({required this.model});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: model.icon != null ? buildIcon(model.icon!) : buildIcon(model.id),
    );
  }
}
