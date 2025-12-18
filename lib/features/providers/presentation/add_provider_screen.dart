import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/ai_model.dart';
import '../../../core/models/provider.dart';
import '../widgets/fetch_models_drawer.dart';
import '../widgets/model_card.dart';
import 'add_provider_viewmodel.dart';

class AddProviderScreen extends StatefulWidget {
  final Provider? provider;

  const AddProviderScreen({super.key, this.provider});

  @override
  State<AddProviderScreen> createState() => _AddProviderScreenState();
}

class _AddProviderScreenState extends State<AddProviderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AddProviderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide FAB based on tab
    });
    _viewModel = AddProviderViewModel();
    _viewModel.initialize(widget.provider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showFetchModelsDrawer,
              icon: const Icon(Icons.cloud_download),
              label: Text('settings.fetch_models'.tr()),
              backgroundColor: Colors.blue,
            )
          : null,
      appBar: AppBar(
        title: Text(
          widget.provider != null
              ? 'settings.edit_provider'.tr()
              : 'settings.add_provider'.tr(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'settings.edit_tab'.tr()),
            Tab(text: 'settings.models_tab'.tr()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _viewModel.saveProvider(
              context,
              existingProvider: widget.provider,
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEditTab(), _buildModelsTab()],
      ),
    );
  }

  Widget _buildEditTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ProviderType>(
              initialValue: _viewModel.selectedType,
              decoration: InputDecoration(
                labelText: 'settings.provider_type'.tr(),
                border: const OutlineInputBorder(),
              ),
              items: ProviderType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _viewModel.updateSelectedType(value);
                  _updateNameForType(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.nameController,
              decoration: InputDecoration(
                labelText: 'settings.name'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.apiKeyController,
              decoration: InputDecoration(
                labelText: 'settings.api_key'.tr(),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _viewModel.baseUrlController,
              decoration: InputDecoration(
                labelText: 'settings.base_url'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Custom routes'),
              subtitle: Text(_viewModel.selectedType.name),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildCustomRoutesSection(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'settings.custom_headers'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _viewModel.addHeader,
                ),
              ],
            ),
            ..._viewModel.headers.asMap().entries.map((entry) {
              final index = entry.key;
              final header = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: header.key,
                        decoration: InputDecoration(
                          labelText: 'settings.header_key'.tr(),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: header.value,
                        decoration: InputDecoration(
                          labelText: 'settings.header_value'.tr(),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => _viewModel.removeHeader(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCustomRoutesSection() {
    switch (_viewModel.selectedType) {
      case ProviderType.google:
        return Column(
          children: [
            _routeField(_viewModel.googleGenerateContentController, 'Generate Content'),
            const SizedBox(height: 8),
            _routeField(_viewModel.googleGenerateContentStreamController, 'Generate Content Stream'),
            const SizedBox(height: 8),
            _routeField(_viewModel.googleModelsRouteController, 'Models'),
          ],
        );
      case ProviderType.openai:
        return Column(
          children: [
            _routeField(_viewModel.openAIChatCompletionsRouteController, 'Chat Completions'),
            const SizedBox(height: 8),
            _routeField(_viewModel.openAIResponsesRouteController, 'Responses'),
            const SizedBox(height: 8),
            _routeField(_viewModel.openAIEmbeddingsRouteController, 'Embeddings'),
            const SizedBox(height: 8),
            _routeField(_viewModel.openAIModelsRouteController, 'Models'),
          ],
        );
      case ProviderType.anthropic:
        return Column(
          children: [
            _routeField(_viewModel.anthropicMessagesRouteController, 'Messages'),
            const SizedBox(height: 8),
            _routeField(_viewModel.anthropicModelsRouteController, 'Models'),
          ],
        );
      case ProviderType.ollama:
        return Column(
          children: [
            _routeField(_viewModel.ollamaChatRouteController, 'Chat'),
            const SizedBox(height: 8),
            _routeField(_viewModel.ollamaTagsRouteController, 'Tags'),
          ],
        );
    }
  }

  Widget _routeField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildModelsTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Models Section Header
              Row(
                children: [
                  Icon(Icons.model_training, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'settings.selected_models'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Selected Models List
              Expanded(
                child: _viewModel.selectedModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.model_training,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'settings.no_models_selected'.tr(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'settings.tap_fab_to_add'.tr(),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _viewModel.selectedModels.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final model = _viewModel.selectedModels[index];
                          return ModelCard(
                            model: model,
                            onTap: () => _showModelCapabilities(model),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _viewModel.removeModel(model.name),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFetchModelsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FetchModelsDrawer(
        availableModels: _viewModel.availableModels,
        selectedModels: _viewModel.selectedModels,
        isFetchingModels: _viewModel.isFetchingModels,
        onFetchModels: () => _viewModel.fetchModels(context),
        onAddModel: _viewModel.addModelDirectly,
        onRemoveModel: _viewModel.removeModelDirectly,
        onShowCapabilities: _showModelCapabilities,
      ),
    );
  }

  void _updateNameForType(ProviderType type) {
    if (_viewModel.nameController.text == 'Google' ||
        _viewModel.nameController.text == 'OpenAI' ||
        _viewModel.nameController.text == 'Anthropic') {
      switch (type) {
        case ProviderType.google:
          _viewModel.nameController.text = 'Google';
          break;
        case ProviderType.openai:
          _viewModel.nameController.text = 'OpenAI';
          break;
        case ProviderType.anthropic:
          _viewModel.nameController.text = 'Anthropic';
          break;
        case ProviderType.ollama:
          _viewModel.nameController.text = 'Ollama';
          break;
      }
    }
  }

  void _showModelCapabilities(AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'settings.capabilities'.tr()}: ${model.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'settings.inputs'.tr()}: ${model.input.map((e) => e.name).join(", ")}',
            ),
            const SizedBox(height: 8),
            Text(
              '${'settings.outputs'.tr()}: ${model.output.map((e) => e.name).join(", ")}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('settings.close'.tr()),
          ),
        ],
      ),
    );
  }
}
