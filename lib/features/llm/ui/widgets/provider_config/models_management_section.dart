import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/llm/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/ui/widgets/edit_model_sheet.dart';
import 'package:multigateway/features/llm/ui/widgets/fetch_models_sheet.dart';
import 'package:multigateway/features/llm/ui/widgets/model_card.dart';

/// Section quản lý models (LlmProviderModels)
/// Hiển thị tất cả 4 loại: BasicModel, OllamaModel, GoogleAiModel, GitHubModel
class ModelsManagementSection extends StatelessWidget {
  final AddProviderController controller;

  const ModelsManagementSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tl('Models'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_download),
                    tooltip: tl('Fetch Models'),
                    onPressed: () => _showFetchModelsSheet(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: tl('Add Model'),
                    onPressed: () => _showAddModelSheet(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: controller.selectedModels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.model_training,
                          size: 64,
                          color: Theme.of(context)
                              .disabledColor
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tl('No models added yet'),
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tl('Tap + to add or fetch models'),
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: controller.selectedModels.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final model = controller.selectedModels[index];
                      return ModelCard(
                        model: model,
                        onTap: () => _showEditModelSheet(context, model),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          onPressed: () => controller.removeModel(model.name),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFetchModelsSheet(BuildContext context) {
    controller.fetchModels(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FetchModelsSheet(
        controller: controller,
        onShowCapabilities: (_) {},
      ),
    );
  }

  void _showAddModelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditModelSheet(
        controller: controller,
        onShowCapabilities: (_) {},
      ),
    );
  }

  void _showEditModelSheet(BuildContext context, dynamic model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditModelSheet(
        controller: controller,
        modelToEdit: model,
        onShowCapabilities: (_) {},
      ),
    );
  }
}