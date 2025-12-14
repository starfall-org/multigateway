import 'package:flutter/material.dart';
import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'add_provider_viewmodel.dart';
import '../../agents/widgets/models_drawer.dart';

class AddProviderScreen extends StatefulWidget {
  final LLMProvider? provider;

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
            onPressed: () => _viewModel.saveProvider(context, existingProvider: widget.provider),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEditTab(),
          _buildModelsTab(),
        ],
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
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'settings.custom_headers'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildModelsTab() {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Fetch Models Button
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showModelsDrawer(),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_download,
                          color: Colors.blue[600],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'settings.fetch_models'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _viewModel.availableModels.isEmpty
                                    ? 'settings.tap_to_fetch_models'.tr()
                                    : '${_viewModel.availableModels.length} ${'settings.models_available'.tr()}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Selected Models Section
              Row(
                children: [
                  Icon(Icons.model_training, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'settings.selected_models'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Expanded(
                child: _viewModel.selectedModels.isEmpty
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
                        itemCount: _viewModel.selectedModels.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final model = _viewModel.selectedModels[index];
                          return ListTile(
                            title: Text(model.id),
                            subtitle: Wrap(
                              spacing: 4,
                              children: [
                                ...model.capabilities.map(
                                  (c) => Chip(
                                    label: Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showModelCapabilities(model),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _viewModel.removeModel(model.id),
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

  void _showModelsDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModelsDrawer(
        availableModels: _viewModel.availableModels,
        selectedModels: _viewModel.selectedModels,
        selectedModelToAdd: _viewModel.selectedModelToAdd,
        isFetchingModels: _viewModel.isFetchingModels,
        onFetchModels: () => _viewModel.fetchModels(context),
        onUpdateSelectedModel: _viewModel.updateSelectedModel,
        onAddModel: _viewModel.addModel,
        onRemoveModel: _viewModel.removeModel,
        onShowCapabilities: _showModelCapabilities,
      ),
    );
  }

  void _updateNameForType(ProviderType type) {
    if (_viewModel.nameController.text == 'Google AI' ||
        _viewModel.nameController.text == 'OpenAI' ||
        _viewModel.nameController.text == 'Anthropic') {
      switch (type) {
        case ProviderType.gemini:
          _viewModel.nameController.text = 'Gemini';
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

  void _showModelCapabilities(ModelInfo model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'settings.capabilities'.tr()}: ${model.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'settings.inputs'.tr()}: ${model.inputTypes.map((e) => e.name).join(", ")}'),
            const SizedBox(height: 8),
            Text('${'settings.outputs'.tr()}: ${model.outputTypes.map((e) => e.name).join(", ")}'),
            const SizedBox(height: 8),
            Text(
              '${'settings.capabilities'.tr()}: ${model.capabilities.map((e) => e.name).join(", ")}',
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
