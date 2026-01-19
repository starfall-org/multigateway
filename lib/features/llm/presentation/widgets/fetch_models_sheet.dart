import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/presentation/widgets/model_card.dart';
import 'package:signals_flutter/signals_flutter.dart';

class FetchModelsSheet extends StatefulWidget {
  final EditProviderController controller;

  const FetchModelsSheet({super.key, required this.controller});

  @override
  State<FetchModelsSheet> createState() => _FetchModelsSheetState();
}

class _FetchModelsSheetState extends State<FetchModelsSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getModelId(dynamic model) {
    if (model is LlmModel) return model.id;
    return '';
  }

  String _getModelDisplayName(dynamic model) {
    if (model is LlmModel) return model.displayName;
    return '';
  }

  List<LlmModel> _filterModels(List<LlmModel> models) {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final availableModels = widget.controller.availableModels.value;
      final selectedModels = widget.controller.selectedModels.value;
      final isFetchingModels = widget.controller.isFetchingModels.value;
      final filteredModels = _filterModels(availableModels);

      return _buildContent(
        context,
        colorScheme,
        availableModels,
        selectedModels,
        isFetchingModels,
        filteredModels,
      );
    });
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme,
    List<LlmModel> availableModels,
    List<LlmModel> selectedModels,
    bool isFetchingModels,
    List<LlmModel> filteredModels,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Search bar with actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: tl('Search models...'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                // Add All / Remove All button
                if (availableModels.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      final allAdded = filteredModels.every(
                        (model) => selectedModels.any((m) => m.id == model.id),
                      );

                      if (allAdded) {
                        for (final model in filteredModels) {
                          widget.controller.removeModelDirectly(model);
                        }
                      } else {
                        for (final model in filteredModels) {
                          widget.controller.addModelDirectly(model);
                        }
                      }
                    },
                    icon: Icon(
                      filteredModels.every(
                            (model) =>
                                selectedModels.any((m) => m.id == model.id),
                          )
                          ? Icons.playlist_remove
                          : Icons.playlist_add,
                    ),
                    tooltip:
                        filteredModels.every(
                          (model) =>
                              selectedModels.any((m) => m.id == model.id),
                        )
                        ? tl('Remove All')
                        : tl('Add All'),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(width: 4),
                // Refresh button
                IconButton(
                  onPressed: isFetchingModels
                      ? null
                      : () => widget.controller.fetchModels(context),
                  icon: isFetchingModels
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: tl('Fetch Models'),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Status bar
          if (availableModels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${availableModels.length} ${tl('models available')}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

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
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tl('Tap refresh to fetch models'),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredModels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tl('No models match your search'),
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                        onTap: () => _showCapabilities(context, model),
                        trailing: IconButton(
                          icon: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          onPressed: () {
                            if (isSelected) {
                              widget.controller.removeModelDirectly(model);
                            } else {
                              widget.controller.addModelDirectly(model);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCapabilities(BuildContext context, LlmModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${model.id}'),
            const SizedBox(height: 8),
            Text(tl('Input Capabilities:')),
            Text(model.inputCapabilities.toJson().toString()),
            const SizedBox(height: 8),
            Text(tl('Output Capabilities:')),
            Text(model.outputCapabilities.toJson().toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tl('Close')),
          ),
        ],
      ),
    );
  }
}
