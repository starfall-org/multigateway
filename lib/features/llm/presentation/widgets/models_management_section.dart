import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/llm/presentation/controllers/edit_provider_controller.dart';
import 'package:multigateway/features/llm/presentation/widgets/edit_model_sheet.dart';
import 'package:multigateway/features/llm/presentation/widgets/fetch_models_sheet.dart';
import 'package:multigateway/features/llm/presentation/widgets/model_card.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Section quản lý models (LlmProviderModels)
/// Hiển thị tất cả 4 loại: BasicModel, OllamaModel, GoogleAiModel, GitHubModel
class ModelsManagementSection extends StatelessWidget {
  final EditProviderController controller;

  const ModelsManagementSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedModels = controller.selectedModels.value;

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cloud),
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
              child: selectedModels.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.token,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.4),
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
                      itemCount: selectedModels.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final model = selectedModels[index];
                        return ModelCard(
                          model: model,
                          onTap: () => _showEditModelSheet(context, model),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            onPressed: () => controller.removeModel(model.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  void _showFetchModelsSheet(BuildContext context) {
    controller.fetchModels(context);

    CustomBottomSheet.show(
      context,
      useSafeArea: true,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      padding: EdgeInsets.zero,
      builder: (context, scrollController) => FetchModelsSheet(
        controller: controller,
        scrollController: scrollController,
      ),
    );
  }

  void _showAddModelSheet(BuildContext context) {
    CustomBottomSheet.show(
      context,
      useSafeArea: true,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      padding: EdgeInsets.zero,
      builder: (context, scrollController) => EditModelSheet(
        controller: controller,
        scrollController: scrollController,
      ),
    );
  }

  void _showEditModelSheet(BuildContext context, LlmModel model) {
    CustomBottomSheet.show(
      context,
      useSafeArea: true,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      padding: EdgeInsets.zero,
      builder: (context, scrollController) => EditModelSheet(
        controller: controller,
        modelToEdit: model,
        scrollController: scrollController,
      ),
    );
  }
}
