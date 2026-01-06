import 'package:flutter/foundation.dart';
import 'package:multigateway/app/models/default_options.dart';
import 'package:multigateway/app/storage/shared_prefs_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing default AI models configuration.
class DefaultOptionsStorage extends SharedPreferencesBase<DefaultOptions> {
  static const String _prefix = 'default_models';
  static const String _itemId = 'default_models_config';

  static DefaultOptionsStorage? _instance;

  final ValueNotifier<DefaultOptions> modelsNotifier = ValueNotifier(
    DefaultOptions(
      defaultModels: DefaultModels(),
      defaultProfileId: '',
    ),
  );

  DefaultOptionsStorage(super.prefs) {
    _loadInitial();
    changes.listen((_) {
      final item = getItem(_itemId);
      modelsNotifier.value = item ??
          DefaultOptions(
            defaultModels: DefaultModels(),
            defaultProfileId: '',
          );
    });
  }

  static Future<DefaultOptionsStorage> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = DefaultOptionsStorage(prefs);
    return _instance!;
  }

  static DefaultOptionsStorage get instance {
    if (_instance == null) {
      throw Exception(
        'DefaultOptionsStorage not initialized. Call init() first.',
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
    return item.toJson();
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