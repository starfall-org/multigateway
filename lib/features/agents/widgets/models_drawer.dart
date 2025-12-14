import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ModelsDrawer extends StatefulWidget {
  final List<ModelInfo> availableModels;
  final List<ModelInfo> selectedModels;
  final ModelInfo? selectedModelToAdd;
  final bool isFetchingModels;
  final Function() onFetchModels;
  final Function(ModelInfo?) onUpdateSelectedModel;
  final Function() onAddModel;
  final Function(String) onRemoveModel;
  final Function(ModelInfo) onShowCapabilities;

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
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.model_training, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'settings.manage_models'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fetch Models Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cloud_download, color: Colors.blue[600]),
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
                                          ? Colors.grey
                                          : Colors.green[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: widget.onFetchModels,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: Text('settings.fetch'.tr()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
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
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<ModelInfo>(
                        initialValue: widget.selectedModelToAdd,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: widget.availableModels.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(
                              model.id,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: widget.onUpdateSelectedModel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onAddModel,
                        icon: const Icon(Icons.add, size: 16),
                        label: Text('settings.add_model'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'settings.no_models_selected'.tr(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
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
                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Icon(
                                      Icons.smart_toy,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    model.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Wrap(
                                    spacing: 4,
                                    runSpacing: -4,
                                    children: model.capabilities.take(2).map((capability) {
                                      return Chip(
                                        label: Text(
                                          capability.name,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }).toList(),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () =>
                                            widget.onShowCapabilities(model),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            widget.onRemoveModel(model.id),
                                      ),
                                    ],
                                  ),
                                  onTap: () =>
                                      widget.onShowCapabilities(model),
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
    );
  }
}