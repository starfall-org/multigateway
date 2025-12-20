import 'package:flutter/widgets.dart';
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
  Locale getInitialLocale(Locale deviceLocale) {
    try {
      final preferences = currentPreferences;

      if (preferences.autoDetectLanguage || preferences.languageCode == 'auto') {
        return _getSupportedLocale(deviceLocale);
      } else {
        return _getLocaleFromPreferences(preferences);
      }
    } catch (e) {
      debugPrint('Error loading language preferences: $e');
      return const Locale('en');
    }
  }

  Locale _getSupportedLocale(Locale deviceLocale) {
    try {
      if (deviceLocale.languageCode.isEmpty) {
        return const Locale('en');
      }

      const supportedLocales = [
        Locale('en'),
        Locale('vi'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('fr'),
        Locale('de'),
      ];

      // Exact match language + country
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode &&
            supportedLocale.countryCode == deviceLocale.countryCode) {
          return supportedLocale;
        }
      }

      // Match language only
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode) {
          if (deviceLocale.languageCode == 'zh') {
            return const Locale('zh', 'CN');
          }
          return supportedLocale;
        }
      }

      return const Locale('en');
    } catch (e) {
      debugPrint('Error getting supported locale: $e');
      return const Locale('en');
    }
  }

  Locale _getLocaleFromPreferences(LanguagePreferences preferences) {
    try {
      if (preferences.languageCode.isEmpty) {
        return const Locale('en');
      }

      final supportedLanguages = ['en', 'vi', 'zh', 'ja', 'fr', 'de'];
      if (!supportedLanguages.contains(preferences.languageCode)) {
        return const Locale('en');
      }

      if (preferences.languageCode == 'zh') {
        if (preferences.countryCode != null &&
            (preferences.countryCode == 'CN' ||
                preferences.countryCode == 'TW')) {
          return Locale(preferences.languageCode, preferences.countryCode);
        } else {
          return const Locale('zh', 'CN'); // Default to simplified Chinese
        }
      }

      if (preferences.countryCode != null &&
          preferences.countryCode!.isNotEmpty) {
        return Locale(preferences.languageCode, preferences.countryCode);
      }

      return Locale(preferences.languageCode);
    } catch (e) {
      debugPrint('Error parsing locale from preferences: $e');
      return const Locale('en');
    }
  }
}