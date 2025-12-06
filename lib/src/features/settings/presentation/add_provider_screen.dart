import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      _apiKeyController.text = widget.provider!.apiKey ?? '';
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
      _selectedType = ProviderType.gemini;
      _nameController.text = 'Gemini';
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
      capabilities = [ModelCapability.audioGeneration];
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
    // Validate inputs
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter API Key first')),
      );
      return;
    }

    setState(() {
      _isFetchingModels = true;
    });

    try {
      // Determine the base URL
      String baseUrl = _baseUrlController.text.isNotEmpty
          ? _baseUrlController.text
          : _getDefaultBaseUrl();

      // Ensure baseUrl doesn't end with /
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Build models endpoint URL
      final url = Uri.parse('$baseUrl/models');

      // Build headers
      final headers = {
        'Authorization': 'Bearer ${_apiKeyController.text}',
        'Content-Type': 'application/json',
      };

      // Add custom headers
      for (var entry in _headers) {
        if (entry.key.text.isNotEmpty) {
          headers[entry.key.text] = entry.value.text;
        }
      }

      // Make API request
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Parse response
        final jsonData = json.decode(response.body);
        List models = [];

        if (jsonData['data'] != null && jsonData['data'] is List) {
          // OpenAI-compatible format
          models = (jsonData['data'] as List)
              .map((model) => model['id'] as String)
              .toList();
        } else if (jsonData['models'] != null && jsonData['models'] is List) {
          // Alternative format (some APIs use 'models' instead of 'data')
          models = (jsonData['models'] as List);
        }

        if (models.isEmpty) {
          throw Exception('No models found in API response');
        }

        setState(() {
          _availableModels = models
              .map((model) => _detectCapabilities(model))
              .toList();
          _selectedModelToAdd = _availableModels.isNotEmpty
              ? _availableModels.first
              : null;
          _isFetchingModels = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Found ${models.length} models')),
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please check your API key.');
      } else {
        throw Exception(
          'Failed to fetch models: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      setState(() {
        _isFetchingModels = false;
      });

      if (mounted) {
        String errorMessage = 'Failed to fetch models';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('ClientException')) {
          errorMessage = 'Connection error. Please check URL and network.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Request timed out. Please try again.';
        } else if (e.toString().contains('FormatException')) {
          errorMessage = 'Invalid response format from API.';
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getDefaultBaseUrl() {
    switch (_selectedType) {
      case ProviderType.openai:
        return 'https://api.openai.com';
      case ProviderType.gemini:
        return 'https://generativelanguage.googleapis.com';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com';
      case ProviderType.ollama:
        return 'http://localhost:11434';
      case ProviderType.custom:
        return '';
    }
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
          initialValue: _selectedType,
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
                    case ProviderType.gemini:
                      _nameController.text = 'Gemini';
                      break;
                    case ProviderType.openai:
                      _nameController.text = 'OpenAI';
                      break;
                    case ProviderType.anthropic:
                      _nameController.text = 'Anthropic';
                      break;
                    case ProviderType.ollama:
                      _nameController.text = 'Ollama';
                      break;
                    case ProviderType.custom:
                      _nameController.text = 'Custom';
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
        }),
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
                        initialValue: _selectedModelToAdd,
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
