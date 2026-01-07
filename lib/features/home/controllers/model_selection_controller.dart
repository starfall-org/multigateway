import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multigateway/core/llm/models/legacy_llm_model.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_models_storage.dart';

/// Controller responsible for provider and model selection
class ModelSelectionController extends ChangeNotifier {
  final LlmProviderInfoStorage pInfStorage;
  final LlmProviderModelsStorage pModStorage;

  StreamSubscription? _providerSubscription;
  List<LlmProviderInfo> providers = [];
  Map<String, List<LegacyAiModel>> providerModels = {};

  /// DEPRECATED: Use LlmProviderInfoStorage,
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderName;
  String? selectedModelName;

  ModelSelectionController({
    required this.pInfStorage,
    required this.pModStorage,
  }) {
    _providerSubscription = pInfStorage.changes.listen((_) {
      refreshProviders();
    });
  }

  LegacyAiModel? get selectedLegacyAiModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.name == selectedProviderName,
      );
      final models = providerModels[provider.id];
      if (models == null) return null;
      return models.firstWhere((m) => m.name == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers = pInfStorage.getItems();
    providerModels.clear();

    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
      final modelsObj = pModStorage.getItem(p.id);
      if (modelsObj != null) {
        providerModels[p.id] = modelsObj.toAiModels();
      } else {
        providerModels[p.id] = [];
      }
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName = providerName;
    selectedModelName = modelName;
    notifyListeners();
  }

  void loadSelectionFromSession({String? providerName, String? modelName}) {
    if (providerName != null && modelName != null) {
      selectedProviderName = providerName;
      selectedModelName = modelName;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _providerSubscription?.cancel();
    super.dispose();
  }
}
