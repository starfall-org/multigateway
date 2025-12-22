import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai/default_models.dart';
import 'shared_prefs_base_repository.dart';

/// Repository for managing default AI models configuration.
class DefaultOptionsRepository
    extends SharedPreferencesBaseRepository<DefaultOptions> {
  static const String _prefix = 'default_models';
  static const String _itemId = 'default_models_config';

  static DefaultOptionsRepository? _instance;

  final ValueNotifier<DefaultOptions> modelsNotifier =
      ValueNotifier<DefaultOptions>(DefaultOptions());

  DefaultOptionsRepository(super.prefs) {
    _loadInitial();
    // Auto-refresh notifier on any storage change (no restart needed)
    changes.listen((_) {
      final item = getItem(_itemId);
      if (item != null) {
        modelsNotifier.value = item;
      } else {
        modelsNotifier.value = DefaultOptions();
      }
    });
  }

  static Future<DefaultOptionsRepository> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = DefaultOptionsRepository(prefs);
    return _instance!;
  }

  static DefaultOptionsRepository get instance {
    if (_instance == null) {
      throw Exception(
        'DefaultOptionsRepository not initialized. Call init() first.',
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
  String get prefix => _prefix;

  @override
  String getItemId(DefaultOptions item) => _itemId;

  @override
  Map<String, dynamic> serializeToFields(DefaultOptions item) {
    return {
      'titleGenerationModel': item.titleGenerationModel?.toJson(),
      'chatSummarizationModel': item.chatSummarizationModel?.toJson(),
      'supportOCRModel': item.supportOCRModel?.toJson(),
      'embeddingModel': item.embeddingModel?.toJson(),
      'imageGenerationModel': item.imageGenerationModel?.toJson(),
      'chatModel': item.chatModel?.toJson(),
      'audioGenerationModel': item.audioGenerationModel?.toJson(),
      'videoGenerationModel': item.videoGenerationModel?.toJson(),
      'rerankModel': item.rerankModel?.toJson(),
    };
  }

  @override
  DefaultOptions deserializeFromFields(String id, Map<String, dynamic> fields) {
    return DefaultOptions.fromJson(fields);
  }

  Future<void> updateModels(DefaultOptions models) async {
    await saveItem(models);
    modelsNotifier.value = models;
  }

  DefaultOptions get currentModels => modelsNotifier.value;
}
