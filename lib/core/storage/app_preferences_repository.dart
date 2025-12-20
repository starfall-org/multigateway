import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_preferences.dart';
import 'base_repository.dart';

class AppPreferencesRepository extends BaseRepository<AppPreferences> {
  static const String _boxName = 'app_preferences';

  // Reactive notifier for UI/VM
  final ValueNotifier<AppPreferences> preferencesNotifier =
      ValueNotifier<AppPreferences>(AppPreferences.defaults());

  AppPreferencesRepository(super.box) {
    _loadInitial();
  }

  void _loadInitial() {
    final items = getItems();
    if (items.isNotEmpty) {
      preferencesNotifier.value = items.first;
    }
  }

  static AppPreferencesRepository? _instance;

  static Future<AppPreferencesRepository> init() async {
    if (_instance != null) return _instance!;
    final box = await Hive.openBox<String>(_boxName);
    _instance = AppPreferencesRepository(box);
    return _instance!;
  }

  static AppPreferencesRepository get instance {
    if (_instance == null) {
      throw Exception('AppPreferencesRepository not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get boxName => _boxName;

  @override
  AppPreferences deserializeItem(String json) => AppPreferences.fromJsonString(json);

  @override
  String serializeItem(AppPreferences item) => item.toJsonString();

  // Single settings object, constant id
  @override
  String getItemId(AppPreferences item) => 'app_settings';

  Future<void> updatePreferences(AppPreferences preferences) async {
    try {
      await saveItem(preferences);
      preferencesNotifier.value = preferences;
    } catch (e) {
      throw Exception('Failed to update app preferences: $e');
    }
  }

  AppPreferences get currentPreferences => preferencesNotifier.value;

  // Convenience setters
  Future<void> setPersistChatSelection(bool persist) async {
    final current = currentPreferences;
    await updatePreferences(current.copyWith(persistChatSelection: persist));
  }

  Future<void> setPreferAgentSettings(bool preferAgent) async {
    // Deprecated in new model, but keeping for compatibility if needed or removing
    // final current = currentPreferences;
    // await updatePreferences(current.copyWith(preferAgentSettings: preferAgent));
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(AppPreferences.defaults());
  }

  Future<void> setInitializedIcons(bool initialized) async {
    final current = currentPreferences;
    await updatePreferences(current.copyWith(hasInitializedIcons: initialized));
  }
}