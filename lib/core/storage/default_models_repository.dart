library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/ai/default_models.dart';
import 'base_repository.dart';

/// Repository for managing default AI models configuration.
class DefaultModelsRepository extends BaseRepository<DefaultModels> {
  static const String _boxName = 'default_models';
  static const String _itemId = 'default_models_config';

  static DefaultModelsRepository? _instance;

  final ValueNotifier<DefaultModels> modelsNotifier =
      ValueNotifier<DefaultModels>(DefaultModels());

  DefaultModelsRepository(super.box) {
    _loadInitial();
  }

  static Future<DefaultModelsRepository> init() async {
    if (_instance != null) return _instance!;
    final box = await Hive.openBox<String>(_boxName);
    _instance = DefaultModelsRepository(box);
    return _instance!;
  }

  static DefaultModelsRepository get instance {
    if (_instance == null) {
      throw Exception(
        'DefaultModelsRepository not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  void _loadInitial() {
    final item = getItem(_itemId);
    if (item != null) {
      modelsNotifier.value = item;
    }
  }

  @override
  String get boxName => _boxName;

  @override
  DefaultModels deserializeItem(String json) {
    return DefaultModels.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  String serializeItem(DefaultModels item) {
    return jsonEncode(item.toJson());
  }

  @override
  String getItemId(DefaultModels item) => _itemId;

  Future<void> updateModels(DefaultModels models) async {
    await saveItem(models);
    modelsNotifier.value = models;
  }

  DefaultModels get currentModels => modelsNotifier.value;
}
