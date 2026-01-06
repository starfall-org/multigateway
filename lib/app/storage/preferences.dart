import 'package:flutter/widgets.dart';
import 'package:multigateway/app/models/preferences_setting.dart';
import 'package:multigateway/app/storage/shared_prefs_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage extends SharedPreferencesBase<PreferencesSetting> {
  static const String _prefix = 'app_prefs';

  // Reactive notifier for UI/VM
  final ValueNotifier<PreferencesSetting> preferencesNotifier =
      ValueNotifier<PreferencesSetting>(PreferencesSetting.defaults());

  PreferencesStorage(super.prefs) {
    _loadInitial();
    changes.listen((_) {
      final items = getItems();
      preferencesNotifier.value = items.isNotEmpty
          ? items.first
          : PreferencesSetting.defaults();
    });
  }

  void _loadInitial() {
    final items = getItems();
    if (items.isNotEmpty) {
      preferencesNotifier.value = items.first;
    }
  }

  static PreferencesStorage? _instance;

  static Future<PreferencesStorage> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesStorage(prefs);
    return _instance!;
  }

  static PreferencesStorage get instance {
    if (_instance == null) {
      throw Exception('PreferencesStorage not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(PreferencesSetting item) => 'app_settings';

  @override
  Map<String, dynamic> serializeToFields(PreferencesSetting item) {
    return {
      'persistChatSelection': item.persistChatSelection,
      'hideStatusBar': item.hideStatusBar,
      'hideNavigationBar': item.hideNavigationBar,
      'debugMode': item.debugMode,
      'hasInitializedIcons': item.hasInitializedIcons,
      'vibrationSettings': item.vibrationSettings.toJson(),
      'languageSetting': item.languageSetting.toJson(),
    };
  }

  @override
  PreferencesSetting deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    final vibrationSettingsMap = fields['vibrationSettings'] as Map<String, dynamic>?;
    final languageSettingMap = fields['languageSetting'] as Map<String, dynamic>?;

    return PreferencesSetting(
      persistChatSelection: fields['persistChatSelection'] as bool? ?? false,
      hideStatusBar: fields['hideStatusBar'] as bool? ?? false,
      hideNavigationBar: fields['hideNavigationBar'] as bool? ?? false,
      debugMode: fields['debugMode'] as bool? ?? false,
      hasInitializedIcons: fields['hasInitializedIcons'] as bool? ?? false,
      vibrationSettings: vibrationSettingsMap != null
          ? VibrationSettings.fromJson(vibrationSettingsMap)
          : VibrationSettings.defaults(),
      languageSetting: languageSettingMap != null
          ? LanguageSetting.fromJson(languageSettingMap)
          : LanguageSetting.defaults(),
    );
  }

  Future<void> updatePreferences(PreferencesSetting preferences) async {
    await saveItem(preferences);
    preferencesNotifier.value = preferences;
  }

  PreferencesSetting get currentPreferences => preferencesNotifier.value;

  // Convenience setters
  Future<void> setPersistChatSelection(bool persist) async {
    await updatePreferences(
      currentPreferences.copyWith(persistChatSelection: persist),
    );
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(PreferencesSetting.defaults());
  }

  Future<void> setInitializedIcons(bool initialized) async {
    await updatePreferences(
      currentPreferences.copyWith(hasInitializedIcons: initialized),
    );
  }

  // Language convenience methods
  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    await updatePreferences(
      currentPreferences.copyWith(
        languageSetting: currentPreferences.languageSetting.copyWith(
          languageCode: languageCode,
          countryCode: countryCode,
          autoDetect: false,
        ),
      ),
    );
  }

  Future<void> setAutoDetectLanguage(bool autoDetect) async {
    await updatePreferences(
      currentPreferences.copyWith(
        languageSetting: currentPreferences.languageSetting.copyWith(
          autoDetect: autoDetect,
        ),
      ),
    );
  }

  Locale getInitialLocale(Locale deviceLocale) {
    final languageSetting = currentPreferences.languageSetting;

    if (languageSetting.autoDetect || languageSetting.languageCode == 'auto') {
      return _getSupportedLocale(deviceLocale);
    }
    return _getLocaleFromLanguageSetting(languageSetting);
  }

  Locale _getSupportedLocale(Locale deviceLocale) {
    if (deviceLocale.languageCode.isEmpty) return const Locale('en');

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
    for (final locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode &&
          locale.countryCode == deviceLocale.countryCode) {
        return locale;
      }
    }

    // Match language only
    for (final locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return deviceLocale.languageCode == 'zh'
            ? const Locale('zh', 'CN')
            : locale;
      }
    }

    return const Locale('en');
  }

  Locale _getLocaleFromLanguageSetting(LanguageSetting languageSetting) {
    if (languageSetting.languageCode.isEmpty) return const Locale('en');

    const supportedLanguages = ['en', 'vi', 'zh', 'ja', 'fr', 'de'];
    if (!supportedLanguages.contains(languageSetting.languageCode)) {
      return const Locale('en');
    }

    if (languageSetting.languageCode == 'zh') {
      if (languageSetting.countryCode == 'CN' || 
          languageSetting.countryCode == 'TW') {
        return Locale(languageSetting.languageCode, languageSetting.countryCode);
      }
      return const Locale('zh', 'CN');
    }

    return languageSetting.countryCode != null && 
           languageSetting.countryCode!.isNotEmpty
        ? Locale(languageSetting.languageCode, languageSetting.countryCode)
        : Locale(languageSetting.languageCode);
  }
}
