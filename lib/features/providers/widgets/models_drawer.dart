import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/ai/ai_model.dart';
import '../../../core/widgets/dropdown.dart';
import '../../settings/widgets/settings_card.dart';
import '../../../core/widgets/item_card.dart';

class ModelsDrawer extends StatefulWidget {
  final List<AIModel> availableModels;
  final List<AIModel> selectedModels;
  final AIModel? selectedModelToAdd;
  final bool isFetchingModels;
  final Function() onFetchModels;
  final Function(AIModel?) onUpdateSelectedModel;
  final Function() onAddModel;
  final Function(String) onRemoveModel;
  final Function(AIModel) onShowCapabilities;

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
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width, // Tối đa chiều ngang
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height * 0.5, // Mặc định 1/2 chiều dọc
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
                  Icon(Icons.model_training,
                      color: Theme.of(context).colorScheme.onPrimary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'settings.manage_models'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary),
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
                                'settings.fetch_models'.tr(),
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
                                        ? 'settings.no_models_fetched'.tr()
                                        : '${widget.availableModels.length} ${'settings.models_available'.tr()}',
                                    style: TextStyle(
                                      color: widget.availableModels.isEmpty
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: widget.onFetchModels,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: Text('settings.fetch'.tr()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
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
                        'settings.available_models'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CommonDropdown<AIModel>(
                        value: widget.selectedModelToAdd,
                        options: widget.availableModels.map((model) {
                          return DropdownOption<AIModel>(
                            value: model,
                            label: model.name,
                            icon: const Icon(Icons.smart_toy),
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
                          label: Text('settings.add_model'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Selected Models Section
                    Text(
                      'settings.selected_models'.tr(),
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
                                    'settings.no_models_selected'.tr(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                                return ItemCard(
                                  layout: ItemCardLayout.list,
                                  title: model.name,
                                  icon: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(
                                      Icons.smart_toy,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () =>
                                            widget.onShowCapabilities(model),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        onPressed: () =>
                                            widget.onRemoveModel(model.name),
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
