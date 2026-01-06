import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:llm/llm.dart';
import '../../../../core/llm/data/provider_info_storage.dart';
import 'package:llm/models/llm_model/base.dart';
import '../../../../app/translate/tl.dart';

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
  final TextEditingController openAIChatCompletionsRouteController = TextEditingController();
  final TextEditingController openAIModelsRouteOrUrlController = TextEditingController();

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

  void initialize(Provider? provider) {
    if (provider != null) {
      nameController.text = provider.name;
      apiKeyController.text = provider.apiKey ?? '';
      baseUrlController.text = provider.baseUrl;
      selectedType = provider.type;
      
      // Headers
      provider.headers.forEach((k, v) {
        headers.add(HeaderPair(k: k, v: v));
      });

      // Special handling based on type
      if (provider.type == ProviderType.openai) {
        openAIChatCompletionsRouteController.text = provider.openAIRoutes.chatCompletion ?? '';
        openAIModelsRouteOrUrlController.text = provider.openAIRoutes.modelsRouteOrUrl ?? '';
        // Heuristic for Azure?
        if (provider.baseUrl.contains('azure')) {
          azureAI = true;
        }
      } else if (provider.type == ProviderType.googleai) {
        if (provider.vertexAIConfig != null) {
          vertexAI = true;
        }
      }

      selectedModels = List.from(provider.models);
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
      if(context.mounted) context.showErrorSnackBar(e.toString());
    } finally {
      isFetchingModels = false;
      notifyListeners();
    }
  }

  Future<void> saveProvider(BuildContext context, {Provider? existingProvider}) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      context.showErrorSnackBar(tl('Name is required'));
      return;
    }

    final headerMap = <String, String>{};
    for(var h in headers) {
      if(h.key.text.isNotEmpty) headerMap[h.key.text] = h.value.text;
    }

    final provider = Provider(
      name: name,
      baseUrl: baseUrlController.text.trim(),
      apiKey: apiKeyController.text.trim().isEmpty ? null : apiKeyController.text.trim(),
      type: selectedType,
      headers: headerMap,
      models: selectedModels,
      openAIRoutes: OpenAIRoutes(
        chatCompletion: openAIChatCompletionsRouteController.text.trim().isEmpty ? '/chat/completions' : openAIChatCompletionsRouteController.text.trim(),
        modelsRouteOrUrl: openAIModelsRouteOrUrlController.text.trim().isEmpty ? '/models' : openAIModelsRouteOrUrlController.text.trim(),
      ),
      vertexAIConfig: vertexAI ? VertexAIConfig(projectId: '', location: '') : null,
    );

    final storage = await LlmProviderInfoStorage.init();
    await storage.saveItem(provider); 

    if (context.mounted) {
      Navigator.pop(context);
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
