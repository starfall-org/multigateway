import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ai_gateway/core/storage/provider_repository.dart';
import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class AddProviderViewModel extends ChangeNotifier {
  // Form State
  ProviderType _selectedType = ProviderType.gemini;
  final _nameController = TextEditingController(text: 'Gemini');
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _headers = [];

  // Models State
  List<ModelInfo> _selectedModels = [];
  List<ModelInfo> _availableModels = [];
  ModelInfo? _selectedModelToAdd;
  bool _isFetchingModels = false;

  // Getters
  ProviderType get selectedType => _selectedType;
  TextEditingController get nameController => _nameController;
  TextEditingController get apiKeyController => _apiKeyController;
  TextEditingController get baseUrlController => _baseUrlController;
  List<MapEntry<TextEditingController, TextEditingController>> get headers => _headers;
  List<ModelInfo> get selectedModels => _selectedModels;
  List<ModelInfo> get availableModels => _availableModels;
  ModelInfo? get selectedModelToAdd => _selectedModelToAdd;
  bool get isFetchingModels => _isFetchingModels;

  void initialize(LLMProvider? provider) {
    if (provider != null) {
      _selectedType = provider.type;
      _nameController.text = provider.name;
      _apiKeyController.text = provider.apiKey ?? '';
      _baseUrlController.text = provider.baseUrl ?? '';
      
      provider.headers.forEach((key, value) {
        _headers.add(
          MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      _selectedModels = List.from(provider.models);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    for (var header in _headers) {
      header.key.dispose();
      header.value.dispose();
    }
  }

  void updateSelectedType(ProviderType type) {
    _selectedType = type;
    notifyListeners();
  }

  void addHeader() {
    _headers.add(MapEntry(TextEditingController(), TextEditingController()));
    notifyListeners();
  }

  void removeHeader(int index) {
    _headers[index].key.dispose();
    _headers[index].value.dispose();
    _headers.removeAt(index);
    notifyListeners();
  }

  ModelInfo detectCapabilities(String modelId) {
    List<ModelIO> inputTypes = [ModelIO.text];
    List<ModelIO> outputTypes = [ModelIO.text];
    List<ModelCapability> capabilities = [ModelCapability.textGeneration];

    if (modelId.contains('vision') ||
        modelId.contains('gpt-4-turbo') ||
        modelId.contains('gemini-pro-vision')) {
      inputTypes.add(ModelIO.image);
      capabilities.add(ModelCapability.imageGeneration);
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

  Future<void> fetchModels(BuildContext context) async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('settings.enter_api_key'.tr())),
      );
      return;
    }

    _isFetchingModels = true;
    notifyListeners();

    try {
      String baseUrl = _baseUrlController.text.isNotEmpty
          ? _baseUrlController.text
          : getDefaultBaseUrl();

      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      final url = Uri.parse('$baseUrl/models');

      final headers = {
        'Authorization': 'Bearer ${_apiKeyController.text}',
        'Content-Type': 'application/json',
      };

      for (var entry in _headers) {
        if (entry.key.text.isNotEmpty) {
          headers[entry.key.text] = entry.value.text;
        }
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List models = [];

        if (jsonData['data'] != null && jsonData['data'] is List) {
          models = (jsonData['data'] as List)
              .map((model) => model['id'] as String)
              .toList();
        } else if (jsonData['models'] != null && jsonData['models'] is List) {
          models = (jsonData['models'] as List);
        }

        if (models.isEmpty) {
          throw Exception('No models found in API response');
        }

        _availableModels = models
            .map((model) => detectCapabilities(model))
            .toList();
        _selectedModelToAdd = _availableModels.isNotEmpty
            ? _availableModels.first
            : null;
        _isFetchingModels = false;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings.found_models'.tr(args: [models.length.toString()]))),
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('settings.auth_error'.tr());
      } else {
        throw Exception(
          '${'settings.fetch_error'.tr()}: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      _isFetchingModels = false;
      notifyListeners();

      if (context.mounted) {
        String errorMessage = 'settings.fetch_error'.tr();
        if (e.toString().contains('SocketException') ||
            e.toString().contains('ClientException')) {
          errorMessage = 'settings.connection_error'.tr();
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'settings.timeout_error'.tr();
        } else if (e.toString().contains('FormatException')) {
          errorMessage = 'settings.invalid_format'.tr();
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

  String getDefaultBaseUrl() {
    switch (_selectedType) {
      case ProviderType.openai:
        return 'https://api.openai.com';
      case ProviderType.gemini:
        return 'https://generativelanguage.googleapis.com';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com';
      case ProviderType.ollama:
        return 'http://localhost:11434';
    }
  }

  void addModel() {
    if (_selectedModelToAdd != null &&
        !_selectedModels.any((m) => m.id == _selectedModelToAdd!.id)) {
      _selectedModels.add(_selectedModelToAdd!);
      notifyListeners();
    }
  }

  void removeModel(String modelId) {
    _selectedModels.removeWhere((m) => m.id == modelId);
    notifyListeners();
  }

  void updateSelectedModel(ModelInfo? model) {
    _selectedModelToAdd = model;
    notifyListeners();
  }

  Future<void> saveProvider(BuildContext context, {LLMProvider? existingProvider}) async {
    if (_nameController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('settings.fill_required'.tr())),
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
      id: existingProvider?.id ?? const Uuid().v4(),
      type: _selectedType,
      name: _nameController.text,
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text.isNotEmpty
          ? _baseUrlController.text
          : null,
      headers: headersMap,
      models: _selectedModels,
    );

    if (existingProvider != null) {
      await repository.updateProvider(provider);
    } else {
      await repository.addProvider(provider);
    }

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }
}