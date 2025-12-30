import 'package:flutter/material.dart';
import '../../../../core/llm/models/llm_model/base.dart';
import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/common_dropdown.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/utils/icon_builder.dart';
import '../controllers/edit_provider_controller.dart';
import '../widgets/edit_model_sheet.dart';
import '../widgets/fetch_models_sheet.dart';
import '../widgets/model_card.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: _showFetchModelsSheet,
                  child: const Icon(Icons.cloud_download),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _showAddModelDrawer,
                  child: const Icon(Icons.note_add),
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: () => _viewModel.saveProvider(
                context,
                existingProvider: widget.provider,
              ),
              label: const Text('Save'),
              icon: const Icon(Icons.save),
            ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.edit)),
            Tab(icon: Icon(Icons.token)),
            Tab(icon: Icon(Icons.http)),
          ],
        ),
      ),

      body: SafeArea(
        top: true,
        bottom: true,
        child: TabBarView(
          controller: _tabController,
          children: [_buildEditTab(), _buildModelsTab(), _buildHttpTab()],
        ),
      ),
    );
  }

  Widget _buildEditTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CommonDropdown<ProviderType>(
                value: _viewModel.selectedType,
                labelText: tl('Compatibility'),
                options: ProviderType.values.map((type) {
                  return DropdownOption<ProviderType>(
                    value: type,
                    label: type.name,
                    icon: buildLogoIcon(
                      _viewModel.vertexAI
                          ? 'vertex-color'
                          : _viewModel.azureAI
                          ? 'azure-color'
                          : type == ProviderType.openai
                          ? 'openai'
                          : type == ProviderType.google
                          ? 'aistudio'
                          : type == ProviderType.anthropic
                          ? 'anthropic'
                          : 'ollama',
                      size: 24,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _viewModel.updateSelectedType(value);
                    _updateNameForType(value);
                  }
                },
              ),
              if (_viewModel.selectedType == ProviderType.openai)
                CheckboxListTile(
                  title: Text(tl('Azure AI')),
                  value: _viewModel.azureAI,
                  onChanged: (value) {
                    if (value != null) {
                      _viewModel.updateAzureAI(value);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              if (_viewModel.selectedType == ProviderType.google)
                CheckboxListTile(
                  title: Text(tl('Vertex AI')),
                  value: _viewModel.vertexAI,
                  onChanged: (value) {
                    if (value != null) {
                      _viewModel.updateVertexAI(value);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _viewModel.nameController,
                label: 'Name',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _viewModel.apiKeyController,
                label: 'API Key',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _viewModel.baseUrlController,
                label: 'Base URL',
              ),

              const SizedBox(height: 8),
              if (_viewModel.selectedType == ProviderType.openai)
                CheckboxListTile(
                  title: Text(tl('Responses API')),
                  value: _viewModel.responsesApi,
                  onChanged: (value) {
                    if (value != null) {
                      _viewModel.updateResponsesApi(value);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomRoutesSection() {
    switch (_viewModel.selectedType) {
      case ProviderType.openai:
        return Column(
          children: [
            _routeField(
              _viewModel.openAIChatCompletionsRouteController,
              'Chat Completions Path',
            ),
            const SizedBox(height: 8),
            _routeField(
              _viewModel.openAIModelsRouteOrUrlController,
              'List Models Path or URL',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _routeField(TextEditingController controller, String label) {
    return CustomTextField(controller: controller, label: label);
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
                            onTap: () => _showEditModelSheet(model),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
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

  Widget _buildHttpTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_viewModel.selectedType == ProviderType.openai &&
                  _viewModel.responsesApi == false)
                ExpansionTile(
                  title: Text(tl('Custom Routes')),
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
                    tl('Headers'),
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
              const SizedBox(height: 8),
              ..._viewModel.headers.asMap().entries.map((entry) {
                final index = entry.key;
                final header = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: header.key,
                          label: 'Key',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          controller: header.value,
                          label: 'Value',
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _viewModel.removeHeader(index),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFetchModelsSheet() {
    _viewModel.fetchModels(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          FetchModelsSheet(viewModel: _viewModel, onShowCapabilities: (_) {}),
    );
  }

  void _showAddModelDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          EditModelSheet(viewModel: _viewModel, onShowCapabilities: (_) {}),
    );
  }

  void _showEditModelSheet(AIModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditModelSheet(
        viewModel: _viewModel,
        modelToEdit: model,
        onShowCapabilities: (_) {},
      ),
    );
  }

  void _updateNameForType(ProviderType type) {
    if (_viewModel.nameController.text == 'Google' ||
        _viewModel.nameController.text == 'OpenAI' ||
        _viewModel.nameController.text == 'Anthropic' ||
        _viewModel.nameController.text == 'Ollama') {
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
}
