import 'package:flutter/material.dart';
import 'package:llm/llm.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/ui/widgets/model_card.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_card.dart';

class FetchModelsSheet extends StatelessWidget {
  final AddProviderViewModel viewModel;
  final Function(AIModel) onShowCapabilities;

  const FetchModelsSheet({
    super.key,
    required this.viewModel,
    required this.onShowCapabilities,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final availableModels = viewModel.availableModels;
        final selectedModels = viewModel.selectedModels;
        final isFetchingModels = viewModel.isFetchingModels;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_download,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tl('Fetch Models'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Fetch Button Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: SettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFetchingModels)
                        const LinearProgressIndicator()
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                availableModels.isEmpty
                                    ? 'No models fetched'
                                    : '${availableModels.length} ${'models available'}',
                                style: TextStyle(
                                  color: availableModels.isEmpty
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => viewModel.fetchModels(context),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: Text(tl('Fetch')),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Models List
              Expanded(
                child: availableModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tl('Tap to fetch models'),
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SafeArea(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: availableModels.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final model = availableModels[index];
                            final isSelected = selectedModels.any(
                              (AIModel m) => m.name == model.name,
                            );

                            return ModelCard(
                              model: model,
                              onTap: () => onShowCapabilities(model),
                              trailing: IconButton(
                                icon: Icon(
                                  isSelected ? Icons.close : Icons.add_circle,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
                                onPressed: () {
                                  if (isSelected) {
                                    viewModel.removeModelDirectly(model);
                                  } else {
                                    viewModel.addModelDirectly(model);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
