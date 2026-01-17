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
import 'package:signals/signals.dart';
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

class AddProviderController {
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
  final selectedType = signal<ProviderType>(ProviderType.openai);
  final selectedAuthMethod = signal<AuthMethod>(AuthMethod.bearerToken);
  final TextEditingController customHeaderKeyController =
      TextEditingController();
  final responsesApi = signal<bool>(false);
  final supportStream = signal<bool>(true);

  // Headers
  final headers = signal<List<HeaderPair>>([]);

  // Models - Using new model types from llm package
  final availableModels = signal<List<dynamic>>(
    [],
  ); // Can be BasicModel, OllamaModel, GoogleAiModel
  final selectedModels = signal<List<dynamic>>(
    [],
  ); // Can be BasicModel, OllamaModel, GoogleAiModel
  final isFetchingModels = signal<bool>(false);

  void initialize({
    LlmProviderInfo? providerInfo,
    LlmProviderConfig? providerConfig,
    LlmProviderModels? providerModels,
  }) {
    if (providerInfo != null) {
      nameController.text = providerInfo.name;
      apiKeyController.text = providerInfo.auth.key ?? '';
      baseUrlController.text = providerInfo.baseUrl;
      selectedType.value = providerInfo.type;

      if (providerConfig != null) {
        responsesApi.value = providerConfig.responsesApi;
        supportStream.value = providerConfig.supportStream;

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
        final headersList = <HeaderPair>[];
        providerConfig.headers?.forEach((k, v) {
          headersList.add(HeaderPair(k: k, v: v.toString()));
        });
        headers.value = headersList;
      }

      if (providerModels != null) {
        // Extract models from LlmProviderModels and convert to their origin types
        selectedModels.value = providerModels.models
            .where((model) => model != null && model.origin != null)
            .map((model) => model!.origin)
            .toList();
      }
    } else {
      baseUrlController.text = 'https://api.openai.com/v1';
    }
  }

  void updateSelectedType(ProviderType type) {
    selectedType.value = type;
    // Set defaults
    switch (type) {
      case ProviderType.openai:
        baseUrlController.text = 'https://api.openai.com/v1';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.anthropic:
        baseUrlController.text = 'https://api.anthropic.com/v1';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.ollama:
        baseUrlController.text = 'http://localhost:11434/api';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.googleai:
        baseUrlController.text = '';
        selectedAuthMethod.value = AuthMethod.queryParam;
        break;
    }
  }

  void updateResponsesApi(bool value) {
    responsesApi.value = value;
  }

  void updateSupportStream(bool value) {
    supportStream.value = value;
  }

  void updateAuthMethod(AuthMethod method) {
    selectedAuthMethod.value = method;
  }

  void updateCustomHeaderKey(String value) {
    customHeaderKeyController.text = value;
  }

  void addHeader() {
    final list = List<HeaderPair>.from(headers.value);
    list.add(HeaderPair());
    headers.value = list;
  }

  void removeHeader(int index) {
    final list = List<HeaderPair>.from(headers.value);
    if (index >= 0 && index < list.length) {
      list[index].dispose();
      list.removeAt(index);
      headers.value = list;
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
    final list = List<dynamic>.from(selectedModels.value);
    list.removeWhere((m) => _getModelName(m) == modelName);
    selectedModels.value = list;
  }

  void removeModelDirectly(dynamic model) {
    removeModel(_getModelName(model));
  }

  void addModelDirectly(dynamic model) {
    final modelName = _getModelName(model);
    final list = List<dynamic>.from(selectedModels.value);
    if (!list.any((m) => _getModelName(m) == modelName)) {
      list.add(model);
      selectedModels.value = list;
    }
  }

  void updateModel(dynamic oldModel, dynamic newModel) {
    final oldName = _getModelName(oldModel);
    final list = List<dynamic>.from(selectedModels.value);
    final index = list.indexWhere((m) => _getModelName(m) == oldName);
    if (index != -1) {
      list[index] = newModel;
      selectedModels.value = list;
    }
  }

  void addNewCustomModel() {
    // Create a BasicModel for custom models
    final newModel = BasicModel(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'New Model',
      ownedBy: 'user',
    );
    final list = List<dynamic>.from(selectedModels.value);
    list.add(newModel);
    selectedModels.value = list;
  }

  Future<void> fetchModels(BuildContext context) async {
    isFetchingModels.value = true;

    try {
      final baseUrl = baseUrlController.text.trim();
      final apiKey = apiKeyController.text.trim();

      if (baseUrl.isEmpty) {
        throw Exception(tl('Base URL is required'));
      }

      // Build custom headers
      final customHeaders = <String, String>{};
      for (var h in headers.value) {
        if (h.key.text.isNotEmpty) {
          customHeaders[h.key.text] = h.value.text;
        }
      }

      // Fetch models based on provider type using new API
      // Keep models in their original types (BasicModel, OllamaModel, GoogleAiModel)
      availableModels.value = await fetch_tools.fetchModels(
        providerType: selectedType.value,
        baseUrl: baseUrl,
        apiKey: apiKey.isEmpty ? null : apiKey,
        customHeaders: customHeaders.isEmpty ? null : customHeaders,
      );

      if (context.mounted) {
        context.showSuccessSnackBar(
          tl('Fetched ${availableModels.value.length} models'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      isFetchingModels.value = false;
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
    for (var h in headers.value) {
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
      type: selectedType.value,
      auth: Authorization(
        type: selectedAuthMethod.value,
        key: apiKeyController.text.trim().isEmpty
            ? null
            : apiKeyController.text.trim(),
      ),
      baseUrl: baseUrlController.text.trim(),
    );

    final providerConfig = LlmProviderConfig(
      id: id,
      headers: headerMap.isEmpty ? null : headerMap,
      responsesApi: responsesApi.value,
      supportStream: supportStream.value,
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

    for (var m in selectedModels.value) {
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
    for (var h in headers.value) {
      h.dispose();
    }
    selectedType.dispose();
    selectedAuthMethod.dispose();
    responsesApi.dispose();
    supportStream.dispose();
    headers.dispose();
    availableModels.dispose();
    selectedModels.dispose();
    isFetchingModels.dispose();
  }
}
