import 'package:flutter/material.dart';
import 'package:multigateway/app/models/preferences_setting.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:signals/signals_flutter.dart';

class PreferencesController {
  PreferencesStorage? _preferencesSp;

  final autoDetect = signal<bool>(true);
  final selectedLanguage = signal<String>('auto');
  final persistChatSelection = signal<bool>(false);
  final vibrationSettings = signal<VibrationSettings>(
    VibrationSettings.defaults(),
  );
  final hideStatusBar = signal<bool>(false);
  final hideNavigationBar = signal<bool>(false);
  final debugMode = signal<bool>(false);
  final continueLastConversation = signal<bool>(true);
  final isInitialized = signal<bool>(false);

  final List<Map<String, dynamic>> supportedLanguages = [
    {'code': 'auto', 'name': 'System Language', 'flag': '🌐'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
    {'code': 'zh_CN', 'name': 'Chinese (Simplified)', 'flag': '🇨🇳'},
    {'code': 'zh_TW', 'name': 'Chinese (Traditional)', 'flag': '🇹🇼'},
    {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
    {'code': 'vi', 'name': 'Vietnamese', 'flag': '🇻🇳'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
  ];

  PreferencesController() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _preferencesSp = await PreferencesStorage.instance;
      isInitialized.value = true;
      _loadPreferences();
      _loadPreferencesSetting();
    } catch (e) {
      // Ghi log lỗi nếu cần thiết
      debugPrint('Error initializing PreferencesController: $e');
    }
  }

  void _loadPreferences() {
    if (_preferencesSp == null) return;

    final languageSetting = _preferencesSp!.currentPreferences.languageSetting;
    autoDetect.value = languageSetting.autoDetect;
    selectedLanguage.value = languageSetting.languageCode;
  }

  void _loadPreferencesSetting() {
    if (_preferencesSp == null) return;

    final appPrefs = _preferencesSp!.currentPreferences;
    persistChatSelection.value = appPrefs.persistChatSelection;
    vibrationSettings.value = appPrefs.vibrationSettings;
    hideStatusBar.value = appPrefs.hideStatusBar;
    hideNavigationBar.value = appPrefs.hideNavigationBar;
    debugMode.value = appPrefs.debugMode;
    continueLastConversation.value = appPrefs.continueLastConversation;
  }

  Future<void> updatePreferencesSetting({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
    bool? continueLastConversation,
  }) async {
    if (_preferencesSp == null) return;

    final newPrefs = _preferencesSp!.currentPreferences.copyWith(
      persistChatSelection: persistChatSelection,
      vibrationSettings: vibrationSettings,
      hideStatusBar: hideStatusBar,
      hideNavigationBar: hideNavigationBar,
      debugMode: debugMode,
      continueLastConversation: continueLastConversation,
    );

    if (persistChatSelection != null) {
      this.persistChatSelection.value = persistChatSelection;
    }
    if (vibrationSettings != null) {
      this.vibrationSettings.value = vibrationSettings;
    }
    if (hideStatusBar != null) this.hideStatusBar.value = hideStatusBar;
    if (hideNavigationBar != null) {
      this.hideNavigationBar.value = hideNavigationBar;
    }
    if (debugMode != null) this.debugMode.value = debugMode;
    if (continueLastConversation != null) {
      this.continueLastConversation.value = continueLastConversation;
    }

    try {
      await _preferencesSp!.updatePreferences(newPrefs);
    } catch (_) {
      // Revert changes on error
      _loadPreferencesSetting();
    }
  }

  Future<void> selectLanguage(String languageCode) async {
    if (_preferencesSp == null) return;

    try {
      selectedLanguage.value = languageCode;
      autoDetect.value = languageCode == 'auto';

      if (languageCode == 'auto') {
        await _preferencesSp!.setAutoDetectLanguage(true);
      } else {
        String? countryCode;
        if (languageCode.contains('_')) {
          final parts = languageCode.split('_');
          countryCode = parts[1];
          languageCode = parts[0];
        }

        await _preferencesSp!.setLanguage(
          languageCode,
          countryCode: countryCode,
        );
      }
    } catch (e) {
      _loadPreferences();
      rethrow;
    }
  }

  Locale getNewLocale() {
    if (_preferencesSp == null) {
      return WidgetsBinding.instance.platformDispatcher.locale;
    }

    final languageSetting = _preferencesSp!.currentPreferences.languageSetting;
    Locale newLocale;

    if (languageSetting.autoDetect || languageSetting.languageCode == 'auto') {
      newLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (newLocale.languageCode == 'zh') {
        newLocale = const Locale('zh', 'CN');
      }
    } else {
      if (languageSetting.countryCode != null) {
        newLocale = Locale(
          languageSetting.languageCode,
          languageSetting.countryCode,
        );
      } else {
        newLocale = Locale(languageSetting.languageCode);
      }
    }

    return newLocale;
  }

  String getCurrentLanguageName() {
    if (autoDetect.value) {
      return 'Auto';
    }

    final selected = supportedLanguages.firstWhere(
      (lang) => lang['code'] == selectedLanguage.value,
      orElse: () => supportedLanguages.first,
    );

    return selected['name'] as String;
  }

  void dispose() {
    autoDetect.dispose();
    selectedLanguage.dispose();
    persistChatSelection.dispose();
    vibrationSettings.dispose();
    hideStatusBar.dispose();
    hideNavigationBar.dispose();
    debugMode.dispose();
    continueLastConversation.dispose();
    isInitialized.dispose();
  }
}
