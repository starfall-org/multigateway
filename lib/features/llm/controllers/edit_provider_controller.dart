import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:llm/llm.dart';
import 'package:multigateway/core/llm/models/legacy_llm_model.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:uuid/uuid.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_config.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:llm/models/llm_model/basic_model.dart';
import 'package:llm/models/llm_model/ollama_model.dart';
import 'package:llm/models/llm_model/googleai_model.dart';
import 'package:llm/models/llm_model/github_model.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_config_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';

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

class AddProviderViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController baseUrlController = TextEditingController();
  final TextEditingController openAIChatCompletionsRouteController =
      TextEditingController();
  final TextEditingController openAIModelsRouteOrUrlController =
      TextEditingController();

  // State
  ProviderType selectedType = ProviderType.openai;
  bool vertexAI = false;
  bool azureAI = false;
  bool responsesApi = false;

  // Headers
  final List<HeaderPair> headers = [];

  // Models
  List<AIModel> availableModels = [];
  List<AIModel> selectedModels = [];
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
        // Headers
        providerConfig.headers?.forEach((k, v) {
          headers.add(HeaderPair(k: k, v: v.toString()));
        });

        openAIChatCompletionsRouteController.text =
            providerConfig.customChatCompletionUrl ?? '';
        openAIModelsRouteOrUrlController.text =
            providerConfig.customListModelsUrl ?? '';
      }

      // Special handling based on type/URL
      if (providerInfo.type == ProviderType.openai) {
        if (providerInfo.baseUrl.contains('azure')) {
          azureAI = true;
        }
      } else if (providerInfo.type == ProviderType.googleai) {
        if (providerInfo.baseUrl.contains('googleapis.com')) {
          vertexAI = false;
        }
      }

      if (providerModels != null) {
        selectedModels = providerModels.toAiModels();
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
        break;
      case ProviderType.anthropic:
        baseUrlController.text = 'https://api.anthropic.com/v1';
        break;
      case ProviderType.ollama:
        baseUrlController.text = 'http://localhost:11434/api';
        break;
      case ProviderType.googleai:
        baseUrlController.text = '';
        break;
    }
    notifyListeners();
  }

  void updateVertexAI(bool value) {
    vertexAI = value;
    notifyListeners();
  }

  void updateAzureAI(bool value) {
    azureAI = value;
    notifyListeners();
  }

  void updateResponsesApi(bool value) {
    responsesApi = value;
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

  // Model Management
  void removeModel(String modelName) {
    selectedModels.removeWhere((m) => m.name == modelName);
    notifyListeners();
  }

  void removeModelDirectly(AIModel model) {
    removeModel(model.name);
  }

  void addModelDirectly(AIModel model) {
    if (!selectedModels.any((m) => m.name == model.name)) {
      selectedModels.add(model);
      notifyListeners();
    }
  }

  void updateModel(AIModel oldModel, AIModel newModel) {
    final index = selectedModels.indexWhere((m) => m.name == oldModel.name);
    if (index != -1) {
      selectedModels[index] = newModel;
      notifyListeners();
    }
  }

  void addNewCustomModel() {
    final newModel = AIModel(
      name: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'New Model',
      type: ModelType.chat,
    );
    selectedModels.add(newModel);
    notifyListeners();
  }

  Future<void> fetchModels(BuildContext context) async {
    isFetchingModels = true;
    notifyListeners();
    try {
      // Basic fetch implementation could go here
      availableModels = [];
    } catch (e) {
      if (context.mounted) context.showErrorSnackBar(e.toString());
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

    final providerInfo = LlmProviderInfo(
      id: id,
      name: name,
      type: selectedType,
      auth: Authorization(
        type: AuthMethod.apiKey,
        key: apiKeyController.text.trim().isEmpty
            ? null
            : apiKeyController.text.trim(),
      ),
      baseUrl: baseUrlController.text.trim(),
    );

    final providerConfig = LlmProviderConfig(
      id: id,
      headers: headerMap,
      responsesApi: responsesApi,
      customChatCompletionUrl:
          openAIChatCompletionsRouteController.text.trim().isEmpty
          ? null
          : openAIChatCompletionsRouteController.text.trim(),
      customListModelsUrl: openAIModelsRouteOrUrlController.text.trim().isEmpty
          ? null
          : openAIModelsRouteOrUrlController.text.trim(),
    );

    // Filter models into categories
    final basicModels = <BasicModel>[];
    final ollamaModels = <OllamaModel>[];
    final googleAiModels = <GoogleAiModel>[];
    final githubModels = <GitHubModel>[];

    // For now, let's treat all added models as BasicModel for simplicity,
    // or we could try to preserve their original types if we had them.
    // Since selectedModels are AIModel, we map them back to BasicModel.
    for (var m in selectedModels) {
      basicModels.add(
        BasicModel(id: m.name, displayName: m.displayName, ownedBy: 'user'),
      );
    }

    final providerModels = LlmProviderModels(
      id: id,
      basicModels: basicModels,
      ollamaModels: ollamaModels,
      googleAiModels: googleAiModels,
      githubModels: githubModels,
    );

    final infoStorage = await LlmProviderInfoStorage.init();
    final configStorage = await LlmProviderConfigStorage.init();
    final modelsStorage = await LlmProviderModelsStorage.init();

    await infoStorage.saveItem(providerInfo);
    await configStorage.saveItem(providerConfig);
    await modelsStorage.saveItem(providerModels);

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    apiKeyController.dispose();
    baseUrlController.dispose();
    openAIChatCompletionsRouteController.dispose();
    openAIModelsRouteOrUrlController.dispose();
    for (var h in headers) {
      h.dispose();
    }
    super.dispose();
  }
}
