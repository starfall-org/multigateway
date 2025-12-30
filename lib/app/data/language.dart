import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/language_setting.dart';
import 'shared_prefs_base.dart';

class LanguageSp extends SharedPreferencesBase<LanguageSetting> {
  static const String _prefix = 'language';

  // Expose a notifier for reactive UI updates
  final ValueNotifier<LanguageSetting> languageNotifier = ValueNotifier(
    LanguageSetting.defaults(),
  );

  LanguageSp(super.prefs) {
    _loadInitialPreferences();
    // Auto-refresh notifier on any storage change (no restart needed)
    changes.listen((_) {
      final items = getItems();
      if (items.isNotEmpty) {
        languageNotifier.value = items.first;
      } else {
        languageNotifier.value = LanguageSetting.defaults();
      }
    });
  }

  void _loadInitialPreferences() {
    final items = getItems();
    if (items.isNotEmpty) {
      languageNotifier.value = items.first;
    }
  }

  static LanguageSp? _instance;

  static Future<LanguageSp> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = LanguageSp(prefs);
    return _instance!;
  }

  static LanguageSp get instance {
    if (_instance == null) {
      throw Exception('LanguageSp not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(LanguageSetting item) => 'language_settings';

  @override
  Map<String, dynamic> serializeToFields(LanguageSetting item) {
    return {
      'languageCode': item.languageCode,
      'countryCode': item.countryCode,
      'autoDetectLanguage': item.autoDetectLanguage,
    };
  }

  @override
  LanguageSetting deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return LanguageSetting(
      languageCode: fields['languageCode'] as String? ?? 'auto',
      countryCode: fields['countryCode'] as String?,
      autoDetectLanguage: fields['autoDetectLanguage'] as bool? ?? true,
    );
  }

  Future<void> updatePreferences(LanguageSetting preferences) async {
    try {
      // We only ever store one item for settings
      await saveItem(preferences);
      languageNotifier.value = preferences;
    } catch (e) {
      throw Exception('Failed to update language preferences: $e');
    }
  }

  LanguageSetting get currentPreferences => languageNotifier.value;

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
    await updatePreferences(LanguageSetting.defaults());
  }

  Locale getInitialLocale(Locale deviceLocale) {
    try {
      final preferences = currentPreferences;

      if (preferences.autoDetectLanguage ||
          preferences.languageCode == 'auto') {
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

  Locale _getLocaleFromPreferences(LanguageSetting preferences) {
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
