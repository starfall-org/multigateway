import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/llm/data/provider_info_storage.dart';
import '../../../../core/llm/models/llm_model/base.dart';
import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class AddProviderViewModel extends ChangeNotifier {
  // Form State
  ProviderType _selectedType = ProviderType.openai;
  bool _vertexAI = false;
  bool _azureAI = false;
  bool _responsesApi = false;
  final _nameController = TextEditingController(text: 'OpenAI');
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _headers =
      [];

  // Custom routes controllers
  final TextEditingController _openAIChatCompletionsRouteController =
      TextEditingController(text: '/chat/completions');
  final TextEditingController _openAIModelsRouteOrUrlController =
      TextEditingController(text: '/models');

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

  // Getters
  bool get vertexAI => _vertexAI;
  bool get azureAI => _azureAI;
  bool get responsesApi => _responsesApi;

  // Expose custom route controllers
  TextEditingController get openAIChatCompletionsRouteController =>
      _openAIChatCompletionsRouteController;
  TextEditingController get openAIModelsRouteOrUrlController =>
      _openAIModelsRouteOrUrlController;

  void initialize(Provider? provider) {
    if (provider != null) {
      _selectedType = provider.type;
      _nameController.text = provider.name;
      _apiKeyController.text = provider.apiKey ?? '';
      _baseUrlController.text = (provider.baseUrl.isNotEmpty == true)
          ? provider.baseUrl
          : getDefaultBaseUrl();
      _vertexAI = provider.vertexAI;
      _azureAI = provider.azureAI;
      _responsesApi = provider.responsesApi;

      provider.headers.forEach((key, value) {
        _headers.add(
          MapEntry(
            TextEditingController(text: key),
            TextEditingController(text: value),
          ),
        );
      });
      _selectedModels = List.from(provider.models);

      // Load custom routes only for OpenAI
      if (_selectedType == ProviderType.openai) {
        final r = provider.openAIRoutes;
        _openAIChatCompletionsRouteController.text = r.chatCompletion;
        _openAIModelsRouteOrUrlController.text = r.modelsRouteOrUrl;
      }
    } else {
      // Defaults for new provider
      _baseUrlController.text = getDefaultBaseUrl();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();

    _openAIChatCompletionsRouteController.dispose();
    _openAIModelsRouteOrUrlController.dispose();

    for (var header in _headers) {
      header.key.dispose();
      header.value.dispose();
    }
    super.dispose();
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
    // Mặc định: text input/output; bổ sung theo heuristic
    AIModelIO input = AIModelIO(text: true, image: false, audio: false);
    AIModelIO output = AIModelIO(text: true, image: false, audio: false);

    final lower = modelId.toLowerCase();

    if (lower.contains('vision') ||
        lower.contains('gpt-4-turbo') ||
        lower.contains('gemini-pro-vision')) {
      input = AIModelIO(image: true, text: false, audio: false);
    }

    if (lower.contains('dall-e')) {
      // Model sinh ảnh: chỉ image output
      output = AIModelIO(image: true, text: false, audio: false);
    }

    if (lower.contains('tts')) {
      // TTS models: chỉ audio output
      output = AIModelIO(audio: true, text: false, image: false);
    }

    return AIModel(
      name: modelId,
      displayName: modelId,
      input: input,
      output: output,
    );
  }

  Future<void> fetchModels(BuildContext context) async {
    if (_apiKeyController.text.isEmpty) {
      context.showInfoSnackBar(tl('settings.enter_api_key'));
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
          modelsRoute = _openAIModelsRouteOrUrlController.text;
          break;
        case ProviderType.google:
          modelsRoute = '/models';
          break;
        case ProviderType.anthropic:
          modelsRoute = '/models';
          break;
        case ProviderType.ollama:
          modelsRoute = '/api/tags';
          break;
      }

      final url = modelsRoute.startsWith('http')
          ? Uri.parse(modelsRoute)
          : Uri.parse(
              '$baseUrl${modelsRoute.startsWith('/') ? '' : '/'}$modelsRoute',
            );

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
          // Normalize to a list of model id/name strings for different providers
          models = (jsonData['models'] as List).map((m) {
            if (m is String) return m;
            if (m is Map) {
              if (m['id'] != null) return m['id'].toString();
              if (m['name'] != null) return m['name'].toString();
            }
            return m.toString();
          }).toList();
        } else if (jsonData['models'] == null &&
            jsonData['model'] == null &&
            jsonData['tags'] != null &&
            jsonData['tags'] is List) {
          // Ollama /tags response
          models = (jsonData['tags'] as List)
              .map(
                (e) =>
                    (e is Map && e['name'] != null) ? e['name'] : e.toString(),
              )
              .toList();
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
          context.showSuccessSnackBar(tl('Found ${models.length} models'));
        }
      } else if (response.statusCode == 401) {
        throw Exception('settings.auth_error');
      } else {
        throw Exception(
          '${'settings.fetch_error'}: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      _isFetchingModels = false;
      notifyListeners();

      if (context.mounted) {
        String errorMessage = 'settings.fetch_error';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('ClientException')) {
          errorMessage = tl("Connection error");
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = tl("Timeout error");
        } else if (e.toString().contains('FormatException')) {
          errorMessage = tl("Invalid format");
        } else {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        context.showErrorSnackBar(errorMessage);
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

  void updateVertexAI(bool value) {
    _vertexAI = value;
    notifyListeners();
  }

  void updateAzureAI(bool value) {
    _azureAI = value;
    notifyListeners();
  }

  void updateResponsesApi(bool value) {
    _responsesApi = value;
    notifyListeners();
  }

  Future<void> saveProvider(
    BuildContext context, {
    Provider? existingProvider,
  }) async {
    if (_nameController.text.isEmpty || _apiKeyController.text.isEmpty) {
      context.showInfoSnackBar(tl('settings.fill_required'));
      return;
    }

    try {
      final repository = await ProviderInfoStorage.init();

      final Map<String, String> headersMap = {};
      for (var entry in _headers) {
        if (entry.key.text.isNotEmpty) {
          headersMap[entry.key.text] = entry.value.text;
        }
      }

      // Build custom routes only for OpenAI
      OpenAIRoutes? openaiRoutes;

      if (_selectedType == ProviderType.openai) {
        openaiRoutes = OpenAIRoutes(
          chatCompletion: _openAIChatCompletionsRouteController.text,
          modelsRouteOrUrl: _openAIModelsRouteOrUrlController.text,
        );
      }

      final provider = Provider(
        name: _nameController.text,
        type: _selectedType,
        apiKey: _apiKeyController.text,
        baseUrl: _baseUrlController.text.isNotEmpty
            ? _baseUrlController.text
            : null,
        vertexAI: _vertexAI,
        azureAI: _azureAI,
        responsesApi: _responsesApi,
        headers: headersMap,
        models: _selectedModels,
        openAIRoutes: openaiRoutes ?? const OpenAIRoutes(),
      );

      if (existingProvider != null) {
        await repository.updateProvider(provider);
      } else {
        await repository.addProvider(provider);
      }

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Error saving provider: $e'));
      }
    }
  }
}
