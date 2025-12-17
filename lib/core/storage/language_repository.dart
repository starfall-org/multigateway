import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/language_preferences.dart';
import 'base_repository.dart';

class LanguageRepository extends BaseRepository<LanguagePreferences> {
  static const String _boxName = 'language_preferences';

  // Expose a notifier for reactive UI updates
  final ValueNotifier<LanguagePreferences> languageNotifier = ValueNotifier(
    LanguagePreferences.defaults(),
  );

  LanguageRepository(super.box) {
    _loadInitialPreferences();
  }

  void _loadInitialPreferences() {
    final items = getItems();
    if (items.isNotEmpty) {
      languageNotifier.value = items.first;
    }
  }

  static LanguageRepository? _instance;

  static Future<LanguageRepository> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final box = await Hive.openBox<String>(_boxName);
    _instance = LanguageRepository(box);
    return _instance!;
  }

  static LanguageRepository get instance {
    if (_instance == null) {
      throw Exception('LanguageRepository not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get boxName => _boxName;

  @override
  LanguagePreferences deserializeItem(String json) =>
      LanguagePreferences.fromJsonString(json);

  @override
  String serializeItem(LanguagePreferences item) => item.toJsonString();

  // Single settings object, so ID is constant
  @override
  String getItemId(LanguagePreferences item) => 'language_settings';

  Future<void> updatePreferences(LanguagePreferences preferences) async {
    try {
      // We only ever store one item for settings
      await saveItem(preferences);
      languageNotifier.value = preferences;
    } catch (e) {
      throw Exception('Failed to update language preferences: $e');
    }
  }

  LanguagePreferences get currentPreferences => languageNotifier.value;

  // Convenience methods
  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    try {
      final current = currentPreferences;
      final updated = current.copyWith(
        languageCode: languageCode,
        countryCode: countryCode,
        autoDetectLanguage: false,
      );
      await updatePreferences(updated);
    } catch (e) {
      throw Exception('Failed to set language: $e');
    }
  }

  Future<void> setAutoDetect(bool autoDetect) async {
    try {
      final current = currentPreferences;
      final updated = current.copyWith(autoDetectLanguage: autoDetect);
      await updatePreferences(updated);
    } catch (e) {
      throw Exception('Failed to set auto detect: $e');
    }
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(LanguagePreferences.defaults());
  }
}