import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/models/ai_model.dart';
import '../../../core/storage/provider_repository.dart';
import '../../../core/models/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class AddProviderViewModel extends ChangeNotifier {
  // Form State
  ProviderType _selectedType = ProviderType.google;
  final _nameController = TextEditingController(text: 'Google');
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _headers =
      [];

  // Custom routes controllers
  final TextEditingController _googleGenerateContentController =
      TextEditingController(text: '/generateContent');
  final TextEditingController _googleGenerateContentStreamController =
      TextEditingController(text: '/generateContentStream');
  final TextEditingController _googleModelsRouteController =
      TextEditingController(text: '/models');

  final TextEditingController _openAIChatCompletionsRouteController =
      TextEditingController(text: '/chat/completions');
  final TextEditingController _openAIResponsesRouteController =
      TextEditingController(text: '/responses');
  final TextEditingController _openAIEmbeddingsRouteController =
      TextEditingController(text: '/embeddings');
  final TextEditingController _openAIModelsRouteController =
      TextEditingController(text: '/models');

  final TextEditingController _anthropicMessagesRouteController =
      TextEditingController(text: '/messages');
  final TextEditingController _anthropicModelsRouteController =
      TextEditingController(text: '/models');

  final TextEditingController _ollamaChatRouteController =
      TextEditingController(text: '/chat');
  final TextEditingController _ollamaTagsRouteController =
      TextEditingController(text: '/tags');

  // Models State
  List<AIModel> _selectedModels = [];
  List<AIModel> _availableModels = [];
  AIModel? _selectedModelToAdd;
  bool _isFetchingModels = false;

  // Getters
  ProviderType get selectedType => _selectedType;
  TextEditingController get nameController => _nameController;
  TextEditingController get apiKeyController => _apiKeyController;
  TextEditingController get baseUrlController => _baseUrlController;
  List<MapEntry<TextEditingController, TextEditingController>> get headers =>
      _headers;
  List<AIModel> get selectedModels => _selectedModels;
  List<AIModel> get availableModels => _availableModels;
  AIModel? get selectedModelToAdd => _selectedModelToAdd;
  bool get isFetchingModels => _isFetchingModels;

  // Expose custom route controllers
  TextEditingController get googleGenerateContentController =>
      _googleGenerateContentController;
  TextEditingController get googleGenerateContentStreamController =>
      _googleGenerateContentStreamController;
  TextEditingController get googleModelsRouteController =>
      _googleModelsRouteController;

  TextEditingController get openAIChatCompletionsRouteController =>
      _openAIChatCompletionsRouteController;
  TextEditingController get openAIResponsesRouteController =>
      _openAIResponsesRouteController;
  TextEditingController get openAIEmbeddingsRouteController =>
      _openAIEmbeddingsRouteController;
  TextEditingController get openAIModelsRouteController =>
      _openAIModelsRouteController;

  TextEditingController get anthropicMessagesRouteController =>
      _anthropicMessagesRouteController;
  TextEditingController get anthropicModelsRouteController =>
      _anthropicModelsRouteController;

  TextEditingController get ollamaChatRouteController =>
      _ollamaChatRouteController;
  TextEditingController get ollamaTagsRouteController =>
      _ollamaTagsRouteController;

  void initialize(Provider? provider) {
    if (provider != null) {
      _selectedType = provider.type;
      _nameController.text = provider.name;
      _apiKeyController.text = provider.apiKey ?? '';
      _baseUrlController.text = (provider.baseUrl.isNotEmpty == true)
          ? provider.baseUrl
          : getDefaultBaseUrl();

      provider.headers.forEach((key, value) {
        _headers.add(
          MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      _selectedModels = List.from(provider.models);

      // Load custom routes if present for the provider type
      switch (_selectedType) {
        case ProviderType.google:
          // Google does not use custom routes
          break;
        case ProviderType.openai:
          final r = provider.openAIRoutes;
          _openAIChatCompletionsRouteController.text = r.chatCompletion;
          _openAIResponsesRouteController.text = r.responses;
          _openAIEmbeddingsRouteController.text = r.embeddings;
          _openAIModelsRouteController.text = r.models;
          break;
        case ProviderType.anthropic:
          final r = provider.anthropicRoutes;
          _anthropicMessagesRouteController.text = r.messages;
          _anthropicModelsRouteController.text = r.models;
          break;
        case ProviderType.ollama:
          final r = provider.ollamaRoutes;
          _ollamaChatRouteController.text = r.chat;
          _ollamaTagsRouteController.text = r.tags;
          break;
      }
    } else {
      // Defaults for new provider
      _baseUrlController.text = getDefaultBaseUrl();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();

    _googleGenerateContentController.dispose();
    _googleGenerateContentStreamController.dispose();
    _googleModelsRouteController.dispose();

    _openAIChatCompletionsRouteController.dispose();
    _openAIResponsesRouteController.dispose();
    _openAIEmbeddingsRouteController.dispose();
    _openAIModelsRouteController.dispose();

    _anthropicMessagesRouteController.dispose();
    _anthropicModelsRouteController.dispose();

    _ollamaChatRouteController.dispose();
    _ollamaTagsRouteController.dispose();

    for (var header in _headers) {
      header.key.dispose();
      header.value.dispose();
    }
  }

  void updateSelectedType(ProviderType type) {
    _selectedType = type;
    // Update base URL field to default for the selected provider
    _baseUrlController.text = getDefaultBaseUrl();
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

  AIModel detectCapabilities(String modelId) {
    List<ModelIOType> inputTypes = [ModelIOType.text];
    List<ModelIOType> outputTypes = [ModelIOType.text];

    if (modelId.contains('vision') ||
        modelId.contains('gpt-4-turbo') ||
        modelId.contains('gemini-pro-vision')) {
      inputTypes.add(ModelIOType.image);
    }

    if (modelId.contains('dall-e')) {
      outputTypes = [ModelIOType.image];
    }

    if (modelId.contains('tts')) {
      outputTypes = [ModelIOType.audio];
    }

    return AIModel(name: modelId, input: inputTypes, output: outputTypes);
  }

  Future<void> fetchModels(BuildContext context) async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('settings.enter_api_key'.tr())));
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

      // Determine models route per provider type
      String modelsRoute;
      switch (_selectedType) {
        case ProviderType.openai:
          modelsRoute = _openAIModelsRouteController.text;
          break;
        case ProviderType.google:
          modelsRoute = _googleModelsRouteController.text;
          break;
        case ProviderType.anthropic:
          modelsRoute = _anthropicModelsRouteController.text;
          break;
        case ProviderType.ollama:
          // For Ollama, tags route returns list of models
          modelsRoute = _ollamaTagsRouteController.text;
          break;
      }
      if (!modelsRoute.startsWith('/')) {
        modelsRoute = '/$modelsRoute';
      }

      final url = Uri.parse('$baseUrl$modelsRoute');

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
        } else if (jsonData['models'] == null &&
            jsonData['model'] == null &&
            jsonData['tags'] != null &&
            jsonData['tags'] is List) {
          // Ollama /tags response
          models = (jsonData['tags'] as List)
              .map((e) => (e is Map && e['name'] != null) ? e['name'] : e.toString())
              .toList();
        }

        if (models.isEmpty) {
          throw Exception('No models found in API response');
        }

        _availableModels =
            models.map((model) => detectCapabilities(model)).toList();
        _selectedModelToAdd =
            _availableModels.isNotEmpty ? _availableModels.first : null;
        _isFetchingModels = false;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'settings.found_models'.tr(args: [models.length.toString()]),
              ),
            ),
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
        return 'https://api.openai.com/v1';
      case ProviderType.google:
        return 'https://generativelanguage.googleapis.com/v1beta';
      case ProviderType.anthropic:
        return 'https://api.anthropic.com/v1';
      case ProviderType.ollama:
        return 'http://localhost:11434';
    }
  }

  void addModel() {
    if (_selectedModelToAdd != null &&
        !_selectedModels.any((m) => m.name == _selectedModelToAdd!.name)) {
      _selectedModels.add(_selectedModelToAdd!);
      notifyListeners();
    }
  }

  void addModelDirectly(AIModel model) {
    if (!_selectedModels.any((m) => m.name == model.name)) {
      _selectedModels.add(model);
      notifyListeners();
    }
  }

  void removeModel(String modelId) {
    _selectedModels.removeWhere((m) => m.name == modelId);
    notifyListeners();
  }

  void removeModelDirectly(AIModel model) {
    _selectedModels.removeWhere((m) => m.name == model.name);
    notifyListeners();
  }

  void updateSelectedModel(AIModel? model) {
    _selectedModelToAdd = model;
    notifyListeners();
  }

  Future<void> saveProvider(
    BuildContext context, {
    Provider? existingProvider,
  }) async {
    if (_nameController.text.isEmpty || _apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('settings.fill_required'.tr())));
      return;
    }

    final repository = await ProviderRepository.init();

    final Map<String, String> headersMap = {};
    for (var entry in _headers) {
      if (entry.key.text.isNotEmpty) {
        headersMap[entry.key.text] = entry.value.text;
      }
    }

    // Build custom routes only for the selected provider type
    OpenAIRoutes? openaiRoutes;
    AnthropicRoutes? anthropicRoutes;
    OllamaRoutes? ollamaRoutes;

    switch (_selectedType) {
      case ProviderType.google:
        // Google does not use custom routes
        break;
      case ProviderType.openai:
        openaiRoutes = OpenAIRoutes(
          chatCompletion: _openAIChatCompletionsRouteController.text,
          responses: _openAIResponsesRouteController.text,
          embeddings: _openAIEmbeddingsRouteController.text,
          models: _openAIModelsRouteController.text,
        );
        break;
      case ProviderType.anthropic:
        anthropicRoutes = AnthropicRoutes(
          messages: _anthropicMessagesRouteController.text,
          models: _anthropicModelsRouteController.text,
        );
        break;
      case ProviderType.ollama:
        ollamaRoutes = OllamaRoutes(
          chat: _ollamaChatRouteController.text,
          tags: _ollamaTagsRouteController.text,
        );
        break;
    }

    final provider = Provider(
      name: _nameController.text,
      type: _selectedType,
      apiKey: _apiKeyController.text,
      baseUrl:
          _baseUrlController.text.isNotEmpty ? _baseUrlController.text : null,
      headers: headersMap,
      models: _selectedModels,
      openAIRoutes: openaiRoutes ?? const OpenAIRoutes(),
      anthropicRoutes: anthropicRoutes ?? const AnthropicRoutes(),
      ollamaRoutes: ollamaRoutes ?? const OllamaRoutes(),
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
