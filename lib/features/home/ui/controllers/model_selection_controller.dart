import 'package:flutter/material.dart';
import 'dart:async';

import 'package:llm/llm.dart';
import 'package:llm/models/llm_model/base.dart';
import '../../../../core/llm/data/provider_info_storage.dart';

/// Controller responsible for provider and model selection
class ModelSelectionController extends ChangeNotifier {
  final LlmProviderInfoStorage pInfStorage;

  StreamSubscription? _providerSubscription;
  List<Provider> providers = [];
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderName;
  String? selectedModelName;

  ModelSelectionController({required this.pInfStorage}) {
    _providerSubscription = pInfStorage.changes.listen((_) {
      refreshProviders();
    });
  }

  AIModel? get selectedAIModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.name == selectedProviderName,
      );
      return provider.models.firstWhere((m) => m.name == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers = pInfStorage.getProviders();
    // Initialize collapse map entries for unseen providers
    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
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
