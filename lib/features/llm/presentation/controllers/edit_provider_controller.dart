import 'package:flutter/material.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/llm/services/fetch_models.dart'
    as fetch_tools;
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:uuid/uuid.dart';

class HeaderPair {
  final TextEditingController key = TextEditingController();
  final TextEditingController value = TextEditingController();

  HeaderPair({String k = '', String v = ''}) {
    key.text = k;
    value.text = v;
  }

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class AddProviderController extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  final TextEditingController customChatCompletionUrlController =
      TextEditingController();
  final TextEditingController customListModelsUrlController =
      TextEditingController();

  // HTTP Proxy controllers
  final TextEditingController httpProxyHostController = TextEditingController();
  final TextEditingController httpProxyPortController = TextEditingController();
  final TextEditingController httpProxyUsernameController =
      TextEditingController();
  final TextEditingController httpProxyPasswordController =
      TextEditingController();

  // SOCKS Proxy controllers
  final TextEditingController socksProxyHostController =
      TextEditingController();
  final TextEditingController socksProxyPortController =
      TextEditingController();
  final TextEditingController socksProxyUsernameController =
      TextEditingController();
  final TextEditingController socksProxyPasswordController =
      TextEditingController();

  // State
  ProviderType selectedType = ProviderType.openai;
  AuthMethod selectedAuthMethod = AuthMethod.bearerToken;
  final TextEditingController customHeaderKeyController =
      TextEditingController();
  bool responsesApi = false;
  bool supportStream = true;

  // Headers
  final List<HeaderPair> headers = [];

  // Models - Using new model types from llm package
  List<dynamic> availableModels =
      []; // Can be BasicModel, OllamaModel, GoogleAiModel
  List<dynamic> selectedModels =
      []; // Can be BasicModel, OllamaModel, GoogleAiModel
  bool isFetchingModels = false;

  void initialize({
    LlmProviderInfo? providerInfo,
    LlmProviderConfig? providerConfig,
    LlmProviderModels? providerModels,
  }) {
    if (providerInfo != null) {
      nameController.text = providerInfo.name;
      apiKeyController.text = providerInfo.auth.key ?? '';
      baseUrlController.text = providerInfo.baseUrl;
      selectedType = providerInfo.type;

      if (providerConfig != null) {
        responsesApi = providerConfig.responsesApi;
        supportStream = providerConfig.supportStream;

        // Custom URLs
        customChatCompletionUrlController.text =
            providerConfig.customChatCompletionUrl ?? '';
        customListModelsUrlController.text =
            providerConfig.customListModelsUrl ?? '';

        // HTTP Proxy
        if (providerConfig.httpProxy != null) {
          httpProxyHostController.text =
              providerConfig.httpProxy!['host']?.toString() ?? '';
          httpProxyPortController.text =
              providerConfig.httpProxy!['port']?.toString() ?? '';
          httpProxyUsernameController.text =
              providerConfig.httpProxy!['username']?.toString() ?? '';
          httpProxyPasswordController.text =
              providerConfig.httpProxy!['password']?.toString() ?? '';
        }

        // SOCKS Proxy
        if (providerConfig.socksProxy != null) {
          socksProxyHostController.text =
              providerConfig.socksProxy!['host']?.toString() ?? '';
          socksProxyPortController.text =
              providerConfig.socksProxy!['port']?.toString() ?? '';
          socksProxyUsernameController.text =
              providerConfig.socksProxy!['username']?.toString() ?? '';
          socksProxyPasswordController.text =
              providerConfig.socksProxy!['password']?.toString() ?? '';
        }

        // Headers
        providerConfig.headers?.forEach((k, v) {
          headers.add(HeaderPair(k: k, v: v.toString()));
        });
      }

      if (providerModels != null) {
        // Extract models from LlmProviderModels and convert to their origin types
        selectedModels = providerModels.models
            .where((model) => model != null && model.origin != null)
            .map((model) => model!.origin)
            .toList();
      }
    } else {
      baseUrlController.text = 'https://api.openai.com/v1';
    }
  }

  void updateSelectedType(ProviderType type) {
    selectedType = type;
    // Set defaults
    switch (type) {
      case ProviderType.openai:
        baseUrlController.text = 'https://api.openai.com/v1';
        selectedAuthMethod = AuthMethod.bearerToken;
        break;
      case ProviderType.anthropic:
        baseUrlController.text = 'https://api.anthropic.com/v1';
        selectedAuthMethod = AuthMethod.bearerToken;
        break;
      case ProviderType.ollama:
        baseUrlController.text = 'http://localhost:11434/api';
        selectedAuthMethod = AuthMethod.bearerToken;
        break;
      case ProviderType.googleai:
        baseUrlController.text = '';
        selectedAuthMethod = AuthMethod.queryParam;
        break;
    }
    notifyListeners();
  }

  void updateResponsesApi(bool value) {
    responsesApi = value;
    notifyListeners();
  }

  void updateSupportStream(bool value) {
    supportStream = value;
    notifyListeners();
  }

  void updateAuthMethod(AuthMethod method) {
    selectedAuthMethod = method;
    notifyListeners();
  }

  void updateCustomHeaderKey(String value) {
    customHeaderKeyController.text = value;
    notifyListeners();
  }

  void addHeader() {
    headers.add(HeaderPair());
    notifyListeners();
  }

  void removeHeader(int index) {
    if (index >= 0 && index < headers.length) {
      headers[index].dispose();
      headers.removeAt(index);
      notifyListeners();
    }
  }

  String _getModelName(dynamic model) {
    if (model is BasicModel) return model.id;
    if (model is OllamaModel) return model.name;
    if (model is GoogleAiModel) return model.name;
    if (model is GitHubModel) return model.name;
    return 'unknown';
  }

  void removeModel(String modelName) {
    selectedModels.removeWhere((m) => _getModelName(m) == modelName);
    notifyListeners();
  }

  void removeModelDirectly(dynamic model) {
    removeModel(_getModelName(model));
  }

  void addModelDirectly(dynamic model) {
    final modelName = _getModelName(model);
    if (!selectedModels.any((m) => _getModelName(m) == modelName)) {
      selectedModels.add(model);
      notifyListeners();
    }
  }

  void updateModel(dynamic oldModel, dynamic newModel) {
    final oldName = _getModelName(oldModel);
    final index = selectedModels.indexWhere((m) => _getModelName(m) == oldName);
    if (index != -1) {
      selectedModels[index] = newModel;
      notifyListeners();
    }
  }

  void addNewCustomModel() {
    // Create a BasicModel for custom models
    final newModel = BasicModel(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'New Model',
      ownedBy: 'user',
    );
    selectedModels.add(newModel);
    notifyListeners();
  }

  Future<void> fetchModels(BuildContext context) async {
    isFetchingModels = true;
    notifyListeners();

    try {
      final baseUrl = baseUrlController.text.trim();
      final apiKey = apiKeyController.text.trim();

      if (baseUrl.isEmpty) {
        throw Exception(tl('Base URL is required'));
      }

      // Build custom headers
      final customHeaders = <String, String>{};
      for (var h in headers) {
        if (h.key.text.isNotEmpty) {
          customHeaders[h.key.text] = h.value.text;
        }
      }

      // Fetch models based on provider type using new API
      // Keep models in their original types (BasicModel, OllamaModel, GoogleAiModel)
      availableModels = await fetch_tools.fetchModels(
        providerType: selectedType,
        baseUrl: baseUrl,
        apiKey: apiKey.isEmpty ? null : apiKey,
        customHeaders: customHeaders.isEmpty ? null : customHeaders,
      );

      if (context.mounted) {
        context.showSuccessSnackBar(
          tl('Fetched ${availableModels.length} models'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      isFetchingModels = false;
      notifyListeners();
    }
  }

  Future<void> saveProvider(
    BuildContext context, {
    LlmProviderInfo? existingProvider,
  }) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      context.showErrorSnackBar(tl('Name is required'));
      return;
    }

    final id = existingProvider?.id ?? Uuid().v4();

    final headerMap = <String, dynamic>{};
    for (var h in headers) {
      if (h.key.text.isNotEmpty) headerMap[h.key.text] = h.value.text;
    }

    // Build HTTP Proxy map
    Map<String, dynamic>? httpProxy;
    if (httpProxyHostController.text.trim().isNotEmpty) {
      httpProxy = {
        'host': httpProxyHostController.text.trim(),
        'port': int.tryParse(httpProxyPortController.text.trim()) ?? 0,
        if (httpProxyUsernameController.text.trim().isNotEmpty)
          'username': httpProxyUsernameController.text.trim(),
        if (httpProxyPasswordController.text.trim().isNotEmpty)
          'password': httpProxyPasswordController.text.trim(),
      };
    }

    // Build SOCKS Proxy map
    Map<String, dynamic>? socksProxy;
    if (socksProxyHostController.text.trim().isNotEmpty) {
      socksProxy = {
        'host': socksProxyHostController.text.trim(),
        'port': int.tryParse(socksProxyPortController.text.trim()) ?? 0,
        if (socksProxyUsernameController.text.trim().isNotEmpty)
          'username': socksProxyUsernameController.text.trim(),
        if (socksProxyPasswordController.text.trim().isNotEmpty)
          'password': socksProxyPasswordController.text.trim(),
      };
    }

    final providerInfo = LlmProviderInfo(
      id: id,
      name: name,
      type: selectedType,
      auth: Authorization(
        type: selectedAuthMethod,
        key: apiKeyController.text.trim().isEmpty
            ? null
            : apiKeyController.text.trim(),
      ),
      baseUrl: baseUrlController.text.trim(),
    );

    final providerConfig = LlmProviderConfig(
      id: id,
      headers: headerMap.isEmpty ? null : headerMap,
      responsesApi: responsesApi,
      supportStream: supportStream,
      httpProxy: httpProxy,
      socksProxy: socksProxy,
      customChatCompletionUrl:
          customChatCompletionUrlController.text.trim().isEmpty
          ? null
          : customChatCompletionUrlController.text.trim(),
      customListModelsUrl: customListModelsUrlController.text.trim().isEmpty
          ? null
          : customListModelsUrlController.text.trim(),
    );

    // Convert selected models to LlmModel format
    final llmModels = <LlmModel>[];

    for (var m in selectedModels) {
      if (m is BasicModel) {
        llmModels.add(
          LlmModel(
            id: m.id,
            displayName: m.displayName,
            type: LlmModelType.chat,
            origin: m,
          ),
        );
      } else if (m is OllamaModel) {
        llmModels.add(
          LlmModel(
            id: m.name,
            displayName: m.name,
            type: LlmModelType.chat,
            origin: m,
          ),
        );
      } else if (m is GoogleAiModel) {
        llmModels.add(
          LlmModel(
            id: m.name,
            displayName: m.displayName,
            type: LlmModelType.chat,
            origin: m,
          ),
        );
      } else if (m is GitHubModel) {
        llmModels.add(
          LlmModel(
            id: m.name,
            displayName: m.name,
            type: LlmModelType.chat,
            origin: m,
          ),
        );
      }
    }

    final providerModels = LlmProviderModels(id: id, models: llmModels);

    final infoStorage = await LlmProviderInfoStorage.init();
    final configStorage = await LlmProviderConfigStorage.init();
    final modelsStorage = await LlmProviderModelsStorage.init();

    await infoStorage.saveItem(providerInfo);
    await configStorage.saveItem(providerConfig);
    await modelsStorage.saveItem(providerModels);

    if (context.mounted) {
      context.showSuccessSnackBar(tl('Provider saved successfully'));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    apiKeyController.dispose();
    baseUrlController.dispose();
    customChatCompletionUrlController.dispose();
    customListModelsUrlController.dispose();
    httpProxyHostController.dispose();
    httpProxyPortController.dispose();
    httpProxyUsernameController.dispose();
    httpProxyPasswordController.dispose();
    socksProxyHostController.dispose();
    socksProxyPortController.dispose();
    socksProxyUsernameController.dispose();
    socksProxyPasswordController.dispose();
    customHeaderKeyController.dispose();
    for (var h in headers) {
      h.dispose();
    }
    super.dispose();
  }
}
