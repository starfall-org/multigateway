import 'package:flutter/material.dart';

import '../../../../core/models/ai/provider.dart';
import '../../../../shared/translate/tl.dart';


class ModelPickerSheet extends StatelessWidget {
  final List<Provider> providers;
  final Map<String, bool> providerCollapsed;
  final String? selectedProviderName;
  final String? selectedModelName;
  final Function(String providerName, bool collapsed) onToggleProvider;
  final Function(String providerName, String modelName) onSelectModel;

  const ModelPickerSheet({
    super.key,
    required this.providers,
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
                            child: Icon(
                              _getProviderIcon(provider.type),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(provider.name),
                          trailing: Icon(
                            collapsed ? Icons.expand_more : Icons.expand_less,
                          ),
                          onTap: () =>
                              onToggleProvider(provider.name, !collapsed),
                        ),
                        if (!collapsed)
                          ...provider.models.map((model) {
                            final isSelected =
                                selectedProviderName == provider.name &&
                                selectedModelName == model.name;
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 56,
                                right: 16,
                                top: 4,
                                bottom: 4,
                              ),
                              title: Text(model.name),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () {
                                onSelectModel(provider.name, model.name);
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

  IconData _getProviderIcon(ProviderType type) {
    switch (type) {
      case ProviderType.google:
        return Icons.android;
      case ProviderType.openai:
        return Icons.smart_toy;
      case ProviderType.anthropic:
        return Icons.psychology;
      case ProviderType.ollama:
        return Icons.terminal;
    }
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required List<Provider> providers,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ModelPickerSheet(
          providers: providers,
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
