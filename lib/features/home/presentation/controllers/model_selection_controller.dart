import 'dart:async';

import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';
import 'package:signals/signals.dart';

/// Controller responsible for provider and model selection
class ModelSelectionController {
  final LlmProviderInfoStorage pInfStorage;
  final LlmProviderModelsStorage pModStorage;

  StreamSubscription? _providerSubscription;
  final providers = listSignal<LlmProviderInfo>([]);
  final providerModels = signal<Map<String, List<LlmModel>>>({});

  /// DEPRECATED: Use LlmProviderInfoStorage,
  final providerCollapsed = signal<Map<String, bool>>({}); // true = collapsed
  final selectedProviderName = signal<String?>(null);
  final selectedModelName = signal<String?>(null);

  ModelSelectionController({
    required this.pInfStorage,
    required this.pModStorage,
  }) {
    _providerSubscription = pInfStorage.changes.listen((_) {
      refreshProviders();
    });
  }

  LlmModel? get selectedLlmModel {
    if (selectedProviderName.value == null || selectedModelName.value == null) {
      return null;
    }
    try {
      final provider = providers.value.firstWhere(
        (p) => p.name == selectedProviderName.value,
      );
      final models = providerModels.value[provider.id];
      if (models == null) return null;
      return models.firstWhere((m) => m.id == selectedModelName.value);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers.value = pInfStorage.getItems();
    final newProviderModels = <String, List<LlmModel>>{};
    final newProviderCollapsed = Map<String, bool>.from(
      providerCollapsed.value,
    );

    for (final p in providers.value) {
      newProviderCollapsed.putIfAbsent(p.name, () => false);
      final modelsObj = pModStorage.getItem(p.id);
      if (modelsObj != null) {
        newProviderModels[p.id] = modelsObj.models
            .whereType<LlmModel>()
            .toList();
      } else {
        newProviderModels[p.id] = [];
      }
    }

    providerModels.value = newProviderModels;
    providerCollapsed.value = newProviderCollapsed;
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    final newMap = Map<String, bool>.from(providerCollapsed.value);
    newMap[providerName] = collapsed;
    providerCollapsed.value = newMap;
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName.value = providerName;
    selectedModelName.value = modelName;
  }

  void loadSelectionFromSession({String? providerName, String? modelName}) {
    if (providerName != null && modelName != null) {
      selectedProviderName.value = providerName;
      selectedModelName.value = modelName;
    }
  }

  void dispose() {
    _providerSubscription?.cancel();
    providers.dispose();
    providerModels.dispose();
    providerCollapsed.dispose();
    selectedProviderName.dispose();
    selectedModelName.dispose();
  }
}
