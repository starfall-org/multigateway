import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/models/ai/ai_model.dart';
import '../../../core/models/provider.dart';
import '../../../core/widgets/dropdown.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../widgets/add_model_drawer.dart';
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
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: _showFetchModelsDrawer,
                  child: const Icon(Icons.cloud_download),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _showAddModelDrawer,
                  child: const Icon(Icons.note_add),
                ),
              ],
            )
          : null,
      appBar: AppBar(
        title: Text(
          widget.provider != null
              ? 'providers.edit_provider'.tr()
              : 'providers.add_provider'.tr(),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.edit)),
            Tab(icon: Icon(Icons.list)),
            Tab(icon: Icon(Icons.abc)),
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
        children: [_buildEditTab(), _buildModelsTab(), _buildABCBTab()],
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
            CommonDropdown<ProviderType>(
              value: _viewModel.selectedType,
              labelText: 'providers.provider_type'.tr(),
              options: ProviderType.values.map((type) {
                return DropdownOption<ProviderType>(
                  value: type,
                  label: type.name,
                  icon: _iconForProviderType(
                    type,
                    _viewModel.vertexAI,
                    _viewModel.azureAI,
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
                title: Text('providers.azure_ai'.tr()),
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
                title: Text('providers.vertex_ai'.tr()),
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
              label: 'providers.name'.tr(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _viewModel.apiKeyController,
              label: 'providers.api_key'.tr(),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _viewModel.baseUrlController,
              label: 'providers.base_url'.tr(),
            ),

            const SizedBox(height: 8),
            if (_viewModel.selectedType == ProviderType.openai)
              CheckboxListTile(
                title: Text('providers.responses_api'.tr()),
                value: _viewModel.responsesApi,
                onChanged: (value) {
                  if (value != null) {
                    _viewModel.updateResponsesApi(value);
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const SizedBox(height: 8),
            if (_viewModel.selectedType == ProviderType.openai &&
                _viewModel.responsesApi == false)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('providers.custom_routes'.tr()),
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
                  'providers.custom_headers.title'.tr(),
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
                      child: CustomTextField(
                        controller: header.key,
                        label: 'providers.custom_headers.header_key'.tr(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: header.value,
                        label: 'providers.custom_headers.header_value'.tr(),
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
              'providers.chat_completions_route'.tr(),
            ),
            const SizedBox(height: 8),
            _routeField(
              _viewModel.openAIModelsRouteOrUrlController,
              'providers.models_route_or_url'.tr(),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _routeField(TextEditingController controller, String label) {
    return CustomTextField(
      controller: controller,
      label: label,
    );
  }

  Widget _iconForProviderType(
    ProviderType type,
    bool isVertexAI,
    bool isAzureFoundry,
  ) {
    switch (type) {
      case ProviderType.google:
        return isVertexAI
            ? Image.asset('assets/brand_logos/vertexai-color.png')
            : Image.asset('assets/brand_logos/aistudio.png');
      case ProviderType.openai:
        return isAzureFoundry
            ? Image.asset('assets/brand_logos/azureai-color.png')
            : Image.asset('assets/brand_logos/openai.png');
      case ProviderType.anthropic:
        return Image.asset('assets/brand_logos/anthropic.png');
      case ProviderType.ollama:
        return Image.asset('assets/brand_logos/ollama.png');
    }
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
                              'providers.no_models_added'.tr(),
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
                            onTap: () => _showModelCapabilities(model),
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

  Widget _buildABCBTab() {
    return Container();
  }

  void _showFetchModelsDrawer() {
    _viewModel.fetchModels(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FetchModelsDrawer(
        viewModel: _viewModel,
        onShowCapabilities: _showModelCapabilities,
      ),
    );
  }

  void _showAddModelDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddModelDrawer(
        viewModel: _viewModel,
        onShowCapabilities: _showModelCapabilities,
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

  void _showModelCapabilities(AIModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'settings.capabilities'.tr()}: ${model.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: model.input
                  .map(
                    (t) => t == ModelIOType.text
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.text_fields),
                              Text(
                                'common.text'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                              ),
                            ],
                          )
                        : t == ModelIOType.image
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined),
                              Text(
                                'common.image'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          )
                        : t == ModelIOType.audio
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.headset_outlined),
                              Text(
                                'common.audio'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          )
                        : Icon(Icons.movie_outlined),
                  )
                  .toList(),
            ),
            Row(
              children: model.output
                  .map(
                    (t) => t == ModelIOType.text
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.text_fields),
                              Text(
                                'common.text'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          )
                        : t == ModelIOType.image
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image),
                              Text(
                                'common.image'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          )
                        : t == ModelIOType.audio
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.music_note),
                              Text(
                                'common.audio'.tr(),
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                          )
                        : Icon(Icons.movie),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }
}
