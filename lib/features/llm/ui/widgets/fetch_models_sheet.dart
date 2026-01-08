import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/ui/widgets/model_card.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_card.dart';

class FetchModelsSheet extends StatefulWidget {
  final AddProviderController controller;
  final Function(dynamic) onShowCapabilities;

  const FetchModelsSheet({
    super.key,
    required this.controller,
    required this.onShowCapabilities,
  });

  @override
  State<FetchModelsSheet> createState() => _FetchModelsSheetState();
}

class _FetchModelsSheetState extends State<FetchModelsSheet> {
  String _searchQuery = '';

  String _getModelId(dynamic model) {
    if (model is BasicModel) return model.id;
    if (model is OllamaModel) return model.model;
    if (model is GoogleAiModel) return model.name;
    return 'unknown';
  }

  String _getModelDisplayName(dynamic model) {
    if (model is BasicModel) return model.displayName;
    if (model is OllamaModel) return model.name;
    if (model is GoogleAiModel) return model.displayName;
    return 'unknown';
  }

  List<dynamic> _filterModels(List<dynamic> models) {
    if (_searchQuery.isEmpty) return models;
    final query = _searchQuery.toLowerCase();
    return models.where((model) {
      final id = _getModelId(model).toLowerCase();
      final displayName = _getModelDisplayName(model).toLowerCase();
      return id.contains(query) || displayName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final availableModels = widget.controller.availableModels;
        final selectedModels = widget.controller.selectedModels;
        final isFetchingModels = widget.controller.isFetchingModels;
        final filteredModels = _filterModels(availableModels);

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
              // Header without title
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
                    const Spacer(),
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

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: tl('Search models...'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Fetch Button Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            if (availableModels.isNotEmpty)
                              TextButton.icon(
                                onPressed: () {
                                  for (final model in filteredModels) {
                                    widget.controller.addModelDirectly(model);
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 18),
                                label: Text(tl('Add All')),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  widget.controller.fetchModels(context),
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
                        child: filteredModels.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Theme.of(context)
                                          .disabledColor
                                          .withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      tl('No models match your search'),
                                      style: TextStyle(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredModels.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final model = filteredModels[index];
                                  final modelId = _getModelId(model);
                                  final isSelected = selectedModels.any(
                                    (m) => _getModelId(m) == modelId,
                                  );

                                  return ModelCard(
                                    model: model,
                                    onTap: () =>
                                        widget.onShowCapabilities(model),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isSelected
                                            ? Icons.close
                                            : Icons.add_circle,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        if (isSelected) {
                                          widget.controller
                                              .removeModelDirectly(model);
                                        } else {
                                          widget.controller
                                              .addModelDirectly(model);
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
