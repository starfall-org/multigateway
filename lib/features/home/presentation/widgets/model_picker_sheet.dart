import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';

class ModelPickerSheet extends StatelessWidget {
  final List<LlmProviderInfo> providers;
  final Map<String, List<LlmModel>> providerModels;
  final Map<String, bool> providerCollapsed;
  final String? selectedProviderName;
  final String? selectedModelName;
  final Function(String providerName, bool collapsed) onToggleProvider;
  final Function(String providerName, String modelName) onSelectModel;

  const ModelPickerSheet({
    super.key,
    required this.providers,
    required this.providerModels,
    required this.providerCollapsed,
    this.selectedProviderName,
    this.selectedModelName,
    required this.onToggleProvider,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
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
            // Models list
            if (providers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(tl('No providers configured')),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: providers.map((provider) {
                    final collapsed = providerCollapsed[provider.name] ?? false;
                    final models = providerModels[provider.id] ?? [];
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
                            child: _ProviderIcon(type: provider.type),
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
                                selectedProviderName == provider.name &&
                                selectedModelName == model.id;
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 16,
                                top: 4,
                                bottom: 4,
                              ),
                              title: Text(model.id),
                              leading: _ModelIcon(path: model.icon),
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
        ),
      ),
    );
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required List<LlmProviderInfo> providers,
    required Map<String, List<LlmModel>> providerModels,
    required Map<String, bool> providerCollapsed,
    String? selectedProviderName,
    String? selectedModelName,
    required Function(String providerName, bool collapsed) onToggleProvider,
    required Function(String providerName, String modelName) onSelectModel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ModelPickerSheet(
          providers: providers,
          providerModels: providerModels,
          providerCollapsed: providerCollapsed,
          selectedProviderName: selectedProviderName,
          selectedModelName: selectedModelName,
          onToggleProvider: onToggleProvider,
          onSelectModel: onSelectModel,
        ),
      ),
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  final ProviderType type;
  const _ProviderIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    switch (type) {
      case ProviderType.google:
        return Icon(Icons.android, color: color);
      case ProviderType.openai:
        return Icon(Icons.token, color: color);
      case ProviderType.anthropic:
        return Icon(Icons.psychology, color: color);
      case ProviderType.ollama:
        return Icon(Icons.terminal, color: color);
    }
  }
}

class _ModelIcon extends StatelessWidget {
  final String? path;
  const _ModelIcon({this.path});

  @override
  Widget build(BuildContext context) {
    if (path != null && path!.isNotEmpty) {
      return Image.asset(
        path!,
        width: 20,
        height: 20,
        errorBuilder: (_, _, _) => const Icon(Icons.token, size: 20),
      );
    }
    return const Icon(Icons.token, size: 20);
  }
}
