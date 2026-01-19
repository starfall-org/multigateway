import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/core.dart';
import 'package:multigateway/features/llm/services/fetch_models.dart'
    as fetch_tools;
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals.dart';
import 'package:uuid/uuid.dart';

class EditProviderController {
  // Basic fields - using signals
  final id = signal<String>('');
  final name = signal<String>('');
  final icon = signal<String>('');
  final apiKey = signal<String>('');
  final baseUrl = signal<String>('');
  final customListModelsUrl = signal<String>('');

  // HTTP Proxy
  final httpProxyHost = signal<String>('');
  final httpProxyPort = signal<String>('');
  final httpProxyUsername = signal<String>('');
  final httpProxyPassword = signal<String>('');

  // SOCKS Proxy
  final socksProxyHost = signal<String>('');
  final socksProxyPort = signal<String>('');
  final socksProxyUsername = signal<String>('');
  final socksProxyPassword = signal<String>('');

  // State
  final selectedType = signal<ProviderType>(ProviderType.openai);
  final selectedAuthMethod = signal<AuthMethod>(AuthMethod.bearerToken);
  final customHeaderKey = signal<String>('');
  final responsesApi = signal<bool>(false);
  final supportStream = signal<bool>(true);

  // Headers - using simple record type
  final headers = signal<List<({String key, String value})>>([]);

  // Models
  final availableModels = signal<List<LlmModel>>([]);
  final selectedModels = signal<List<LlmModel>>([]);
  final isFetchingModels = signal<bool>(false);

  void initialize({
    LlmProviderInfo? providerInfo,
    LlmProviderModels? providerModels,
  }) {
    if (providerInfo != null) {
      id.value = providerInfo.id;
      name.value = providerInfo.name;
      apiKey.value = providerInfo.auth.key ?? '';
      baseUrl.value = providerInfo.baseUrl;
      selectedType.value = providerInfo.type;

      responsesApi.value = providerInfo.config.responsesApi;
      supportStream.value = providerInfo.config.supportStream;
      customListModelsUrl.value =
          providerInfo.config.customListModelsUrl ?? '/models';

      // HTTP Proxy
      httpProxyHost.value =
          providerInfo.config.httpProxy['host']?.toString() ?? '';
      httpProxyPort.value =
          providerInfo.config.httpProxy['port']?.toString() ?? '';
      httpProxyUsername.value =
          providerInfo.config.httpProxy['username']?.toString() ?? '';
      httpProxyPassword.value =
          providerInfo.config.httpProxy['password']?.toString() ?? '';

      // SOCKS Proxy
      socksProxyHost.value =
          providerInfo.config.socksProxy['host']?.toString() ?? '';
      socksProxyPort.value =
          providerInfo.config.socksProxy['port']?.toString() ?? '';
      socksProxyUsername.value =
          providerInfo.config.socksProxy['username']?.toString() ?? '';
      socksProxyPassword.value =
          providerInfo.config.socksProxy['password']?.toString() ?? '';

      // Headers
      headers.value = providerInfo.config.headers.entries
          .map((e) => (key: e.key, value: e.value.toString()))
          .toList();

      if (providerModels != null) {
        selectedModels.value = providerModels.models
            .whereType<LlmModel>()
            .toList();
      }
    } else {
      id.value = Uuid().v4();
    }
  }

  void updateSelectedType(ProviderType type) {
    selectedType.value = type;
    // Set defaults
    switch (type) {
      case ProviderType.openai:
        name.value = 'OpenAI';
        baseUrl.value = 'https://api.openai.com/v1';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.anthropic:
        name.value = 'Anthropic';
        baseUrl.value = 'https://api.anthropic.com/v1';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.ollama:
        name.value = 'Ollama';
        baseUrl.value = 'https://ollama.com/api';
        selectedAuthMethod.value = AuthMethod.bearerToken;
        break;
      case ProviderType.google:
        name.value = 'Google AI Studio';
        baseUrl.value = 'https://generativelanguage.googleapis.com/v1beta';
        selectedAuthMethod.value = AuthMethod.queryParam;
        break;
    }
  }

  void addHeader() {
    headers.value = [...headers.value, (key: '', value: '')];
  }

  void updateHeader(int index, {String? key, String? value}) {
    final list = List.of(headers.value);
    if (index >= 0 && index < list.length) {
      final current = list[index];
      list[index] = (key: key ?? current.key, value: value ?? current.value);
      headers.value = list;
    }
  }

  void removeHeader(int index) {
    if (index >= 0 && index < headers.value.length) {
      final list = List.of(headers.value);
      list.removeAt(index);
      headers.value = list;
    }
  }

  void toggleModel(LlmModel model) {
    final list = List.of(selectedModels.value);
    final index = list.indexWhere((m) => m.id == model.id);
    if (index != -1) {
      list.removeAt(index);
    } else {
      list.add(model);
    }
    selectedModels.value = list;
  }

  void addModelDirectly(LlmModel model) {
    final list = List.of(selectedModels.value);
    if (list.any((m) => m.id == model.id)) return;
    list.add(model);
    selectedModels.value = list;
  }

  void removeModelDirectly(LlmModel model) {
    removeModel(model.id);
  }

  void removeModel(String modelId) {
    final list = List.of(selectedModels.value)
      ..removeWhere((m) => m.id == modelId);
    selectedModels.value = list;
  }

  void updateModel(LlmModel oldModel, LlmModel newModel) {
    final list = List.of(selectedModels.value);
    final index = list.indexWhere((m) => m.id == oldModel.id);
    if (index != -1) {
      list[index] = newModel;
      selectedModels.value = list;
    }
  }

  void addCustomModel({
    required String modelId,
    required String modelDisplayName,
    String? modelIcon,
    required Capabilities inputCapabilities,
    required Capabilities outputCapabilities,
    required Map<String, dynamic> modelInfo,
  }) {
    final newModel = LlmModel(
      id: modelId,
      displayName: modelDisplayName,
      icon: modelIcon,
      providerId: id.value,
      inputCapabilities: inputCapabilities,
      outputCapabilities: outputCapabilities,
      modelInfo: modelInfo,
    );
    selectedModels.value = [...selectedModels.value, newModel];
  }

  Future<void> fetchModels(BuildContext context) async {
    isFetchingModels.value = true;

    try {
      final url = baseUrl.value.trim();
      final key = apiKey.value.trim();

      if (url.isEmpty) {
        throw Exception(tl('Base URL is required'));
      }

      // Build custom headers
      final customHeaders = <String, String>{};
      for (var h in headers.value) {
        if (h.key.isNotEmpty) {
          customHeaders[h.key] = h.value;
        }
      }

      final providerInfo = LlmProviderInfo(
        id: id.value,
        name: name.value,
        type: selectedType.value,
        auth: Authorization(method: selectedAuthMethod.value, key: key),
        icon: icon.value,
        baseUrl: url,
        config: Configuration(
          httpProxy: {
            'host': httpProxyHost.value,
            'port': httpProxyPort.value,
            'username': httpProxyUsername.value,
            'password': httpProxyPassword.value,
          },
          socksProxy: {
            'host': socksProxyHost.value,
            'port': socksProxyPort.value,
            'username': socksProxyUsername.value,
            'password': socksProxyPassword.value,
          },
          supportStream: supportStream.value,
          headers: customHeaders,
          responsesApi: responsesApi.value,
          customListModelsUrl: customListModelsUrl.value,
        ),
      );

      availableModels.value = await fetch_tools.fetchModels(
        providerInfo: providerInfo,
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

  Future<bool> saveProvider(
    BuildContext context, {
    LlmProviderInfo? existingProvider,
  }) async {
    final providerName = name.value.trim();
    if (providerName.isEmpty) {
      context.showErrorSnackBar(tl('Name is required'));
      return false;
    }

    final id = existingProvider?.id ?? Uuid().v4();

    // Build headers map
    final headerMap = <String, dynamic>{};
    for (var h in headers.value) {
      if (h.key.isNotEmpty) {
        headerMap[h.key] = h.value;
      }
    }

    // Build HTTP Proxy map
    final httpProxy = <String, dynamic>{};
    if (httpProxyHost.value.trim().isNotEmpty) {
      httpProxy['host'] = httpProxyHost.value.trim();
      httpProxy['port'] = int.tryParse(httpProxyPort.value.trim()) ?? 0;
      if (httpProxyUsername.value.trim().isNotEmpty) {
        httpProxy['username'] = httpProxyUsername.value.trim();
      }
      if (httpProxyPassword.value.trim().isNotEmpty) {
        httpProxy['password'] = httpProxyPassword.value.trim();
      }
    }

    // Build SOCKS Proxy map
    final socksProxy = <String, dynamic>{};
    if (socksProxyHost.value.trim().isNotEmpty) {
      socksProxy['host'] = socksProxyHost.value.trim();
      socksProxy['port'] = int.tryParse(socksProxyPort.value.trim()) ?? 0;
      if (socksProxyUsername.value.trim().isNotEmpty) {
        socksProxy['username'] = socksProxyUsername.value.trim();
      }
      if (socksProxyPassword.value.trim().isNotEmpty) {
        socksProxy['password'] = socksProxyPassword.value.trim();
      }
    }

    final providerInfo = LlmProviderInfo(
      id: id,
      name: providerName,
      type: selectedType.value,
      auth: Authorization(
        method: selectedAuthMethod.value,
        key: apiKey.value.trim().isEmpty ? null : apiKey.value.trim(),
      ),
      baseUrl: baseUrl.value.trim(),
      config: Configuration(
        headers: headerMap,
        httpProxy: httpProxy,
        socksProxy: socksProxy,
        responsesApi: responsesApi.value,
        supportStream: supportStream.value,
        customListModelsUrl: customListModelsUrl.value.trim().isEmpty
            ? null
            : customListModelsUrl.value.trim(),
      ),
    );

    final providerModels = LlmProviderModels(
      id: id,
      models: selectedModels.value,
    );

    try {
      final infoStorage = await LlmProviderInfoStorage.init();
      final modelsStorage = await LlmProviderModelsStorage.init();

      await infoStorage.saveItem(providerInfo);
      await modelsStorage.saveItem(providerModels);

      if (context.mounted) {
        context.showSuccessSnackBar(tl('Provider saved successfully'));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Failed to save provider: $e'));
      }
      return false;
    }
  }

  void dispose() {
    name.dispose();
    apiKey.dispose();
    baseUrl.dispose();
    customListModelsUrl.dispose();
    httpProxyHost.dispose();
    httpProxyPort.dispose();
    httpProxyUsername.dispose();
    httpProxyPassword.dispose();
    socksProxyHost.dispose();
    socksProxyPort.dispose();
    socksProxyUsername.dispose();
    socksProxyPassword.dispose();
    selectedType.dispose();
    selectedAuthMethod.dispose();
    customHeaderKey.dispose();
    responsesApi.dispose();
    supportStream.dispose();
    headers.dispose();
    availableModels.dispose();
    selectedModels.dispose();
    isFetchingModels.dispose();
  }
}
