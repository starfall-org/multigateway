import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:lmhub/src/core/storage/provider_repository.dart';
import 'package:lmhub/src/features/settings/domain/provider.dart';

class AddProviderScreen extends StatefulWidget {
  final LLMProvider? provider;

  const AddProviderScreen({super.key, this.provider});

  @override
  State<AddProviderScreen> createState() => _AddProviderScreenState();
}

class _AddProviderScreenState extends State<AddProviderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  late ProviderType _selectedType;
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _headers =
      [];

  // Models State
  List<ModelInfo> _selectedModels = [];
  List<ModelInfo> _availableModels = []; // Fetched from API
  ModelInfo? _selectedModelToAdd;
  bool _isFetchingModels = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.provider != null) {
      _selectedType = widget.provider!.type;
      _nameController.text = widget.provider!.name;
      _apiKeyController.text = widget.provider!.apiKey;
      _baseUrlController.text = widget.provider!.baseUrl ?? '';
      widget.provider!.headers.forEach((key, value) {
        _headers.add(
          MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      _selectedModels = List.from(widget.provider!.models);
    } else {
      _selectedType = ProviderType.google;
      _nameController.text = 'Google AI';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    for (var header in _headers) {
      header.key.dispose();
      header.value.dispose();
    }
    super.dispose();
  }

  void _addHeader() {
    setState(() {
      _headers.add(MapEntry(TextEditingController(), TextEditingController()));
    });
  }

  void _removeHeader(int index) {
    setState(() {
      _headers[index].key.dispose();
      _headers[index].value.dispose();
      _headers.removeAt(index);
    });
  }

  ModelInfo _detectCapabilities(String modelId) {
    List<ModelIO> inputTypes = [ModelIO.text];
    List<ModelIO> outputTypes = [ModelIO.text];
    List<ModelCapability> capabilities = [ModelCapability.textGeneration];

    if (modelId.contains('vision') ||
        modelId.contains('gpt-4-turbo') ||
        modelId.contains('gemini-pro-vision')) {
      inputTypes.add(ModelIO.image);
      capabilities.add(
        ModelCapability.imageGeneration,
      ); // Simplified assumption, usually image input
    }

    if (modelId.contains('dall-e')) {
      capabilities = [ModelCapability.imageGeneration];
      outputTypes = [ModelIO.image];
    }

    if (modelId.contains('tts')) {
      capabilities = [ModelCapability.tts];
      outputTypes = [ModelIO.audio];
    }

    return ModelInfo(
      id: modelId,
      inputTypes: inputTypes,
      outputTypes: outputTypes,
      capabilities: capabilities,
    );
  }

  Future<void> _fetchModels() async {
    setState(() {
      _isFetchingModels = true;
    });

    // Mock fetching models for now
    await Future.delayed(const Duration(seconds: 1));

    List<String> modelIds = [];
    switch (_selectedType) {
      case ProviderType.google:
        modelIds = ['gemini-pro', 'gemini-pro-vision', 'gemini-ultra'];
        break;
      case ProviderType.openai:
        modelIds = [
          'gpt-4',
          'gpt-3.5-turbo',
          'gpt-4-turbo',
          'dall-e-3',
          'tts-1',
        ];
        break;
      case ProviderType.anthropic:
        modelIds = ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'];
        break;
    }

    setState(() {
      _availableModels = modelIds.map((id) => _detectCapabilities(id)).toList();
      _selectedModelToAdd = _availableModels.isNotEmpty
          ? _availableModels.first
          : null;
      _isFetchingModels = false;
    });
  }

  void _addModel() {
    if (_selectedModelToAdd != null &&
        !_selectedModels.any((m) => m.id == _selectedModelToAdd!.id)) {
      setState(() {
        _selectedModels.add(_selectedModelToAdd!);
      });
    }
  }

  void _removeModel(String modelId) {
    setState(() {
      _selectedModels.removeWhere((m) => m.id == modelId);
    });
  }

  Future<void> _editModelCapabilities(ModelInfo model) async {
    // Simple dialog to show capabilities for now, editing could be added
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Capabilities: ${model.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inputs: ${model.inputTypes.map((e) => e.name).join(", ")}'),
            const SizedBox(height: 8),
            Text('Outputs: ${model.outputTypes.map((e) => e.name).join(", ")}'),
            const SizedBox(height: 8),
            Text(
              'Capabilities: ${model.capabilities.map((e) => e.name).join(", ")}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProvider() async {
    if (_nameController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Name and API Key')),
      );
      return;
    }

    final repository = await ProviderRepository.init();

    final Map<String, String> headersMap = {};
    for (var entry in _headers) {
      if (entry.key.text.isNotEmpty) {
        headersMap[entry.key.text] = entry.value.text;
      }
    }

    final provider = LLMProvider(
      id: widget.provider?.id ?? const Uuid().v4(),
      type: _selectedType,
      name: _nameController.text,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text.isNotEmpty
          ? _baseUrlController.text
          : null,
      headers: headersMap,
      models: _selectedModels,
    );

    if (widget.provider != null) {
      await repository.updateProvider(provider);
    } else {
      await repository.addProvider(provider);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider != null ? 'Edit Provider' : 'Add Provider'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Edit'),
            Tab(text: 'Models'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveProvider),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEditTab(), _buildModelsTab()],
      ),
    );
  }

  Widget _buildEditTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<ProviderType>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Provider Type',
            border: OutlineInputBorder(),
          ),
          items: ProviderType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
                if (_nameController.text == 'Google AI' ||
                    _nameController.text == 'OpenAI' ||
                    _nameController.text == 'Anthropic') {
                  switch (value) {
                    case ProviderType.google:
                      _nameController.text = 'Google AI';
                      break;
                    case ProviderType.openai:
                      _nameController.text = 'OpenAI';
                      break;
                    case ProviderType.anthropic:
                      _nameController.text = 'Anthropic';
                      break;
                  }
                }
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _baseUrlController,
          decoration: const InputDecoration(
            labelText: 'Base URL (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Custom Headers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addHeader,
            ),
          ],
        ),
        ..._headers.asMap().entries.map((entry) {
          final index = entry.key;
          final header = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: header.key,
                    decoration: const InputDecoration(
                      labelText: 'Key',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: header.value,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => _removeHeader(index),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModelsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _isFetchingModels
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<ModelInfo>(
                        value: _selectedModelToAdd,
                        decoration: const InputDecoration(
                          labelText: 'Available Models',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _availableModels.map((model) {
                          return DropdownMenuItem(
                            value: model,
                            child: Text(model.id),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedModelToAdd = value;
                          });
                        },
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Fetch Models',
                onPressed: _fetchModels,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Model',
                onPressed: _addModel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _selectedModels.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final model = _selectedModels[index];
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
                  onTap: () => _editModelCapabilities(model),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeModel(model.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
