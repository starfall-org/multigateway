import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:multigateway/shared/widgets/common_dropdown.dart';
import 'package:multigateway/shared/widgets/item_card.dart';

class ModelsDrawer extends StatefulWidget {
  final List<LlmModel> availableModels;
  final List<LlmModel> selectedModels;
  final LlmModel? selectedModelToAdd;
  final bool isFetchingModels;
  final Function() onFetchModels;
  final Function(LlmModel) onUpdateSelectedModel;
  final Function() onAddModel;
  final Function(String) onRemoveModel;
  final Function(LlmModel) onShowCapabilities;

  const ModelsDrawer({
    super.key,
    required this.availableModels,
    required this.selectedModels,
    required this.selectedModelToAdd,
    required this.isFetchingModels,
    required this.onFetchModels,
    required this.onUpdateSelectedModel,
    required this.onAddModel,
    required this.onRemoveModel,
    required this.onShowCapabilities,
  });

  @override
  State<ModelsDrawer> createState() => _ModelsDrawerState();
}

class _ModelsDrawerState extends State<ModelsDrawer> {
  String _getModelName(LlmModel model) => model.id;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 60, 8, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.model_training,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tl('settings.manage_models'),
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

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fetch Models Section
                    SettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_download,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                tl('settings.fetch_models'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (widget.isFetchingModels)
                            const LinearProgressIndicator()
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.availableModels.isEmpty
                                        ? 'settings.no_models_fetched'
                                        : '${widget.availableModels.length} ${'settings.models_available'}',
                                    style: TextStyle(
                                      color: widget.availableModels.isEmpty
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant
                                          : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: widget.onFetchModels,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: Text(tl('settings.fetch')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context)
                                              .inputDecorationTheme
                                              .hintStyle
                                              ?.color ??
                                          Theme.of(context).colorScheme.outline,
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Available Models Section
                    if (widget.availableModels.isNotEmpty) ...[
                      Text(
                        tl('settings.available_models'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CommonDropdown<LlmModel>(
                        value: widget.selectedModelToAdd,
                        options: widget.availableModels.map((model) {
                          return DropdownOption<LlmModel>(
                            value: model,
                            label: _getModelName(model),
                            icon: const Icon(Icons.token), // Use Icons.token
                          );
                        }).toList(),
                        onChanged: widget.onUpdateSelectedModel,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onAddModel,
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(tl('settings.add_model')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                            side: BorderSide(
                              color:
                                  Theme.of(
                                    context,
                                  ).inputDecorationTheme.hintStyle?.color ??
                                  Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Selected Models Section
                    Text(
                      tl('settings.selected_models'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: widget.selectedModels.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.model_training,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tl('settings.no_models_selected'),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: widget.selectedModels.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final model = widget.selectedModels[index];
                                final modelName = _getModelName(model);

                                return ItemCard(
                                  layout: ItemCardLayout.list,
                                  title: modelName,
                                  icon: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.token, // Use Icons.token
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () => widget.onShowCapabilities(model),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        onPressed: () =>
                                            widget.onShowCapabilities(model),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                        onPressed: () =>
                                            widget.onRemoveModel(modelName),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
