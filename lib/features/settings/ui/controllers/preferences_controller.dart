import 'package:flutter/material.dart';
import '../../../../app/models/preferences_setting.dart';
import '../../../../app/storage/preferences.dart';

class PreferencesController extends ChangeNotifier {
  final PreferencesStorage _preferencesSp;

  bool _autoDetect = true;
  String _selectedLanguage = 'auto';
  bool _persistChatSelection = false;
  VibrationSettings _vibrationSettings = VibrationSettings.defaults();
  bool _hideStatusBar = false;
  bool _hideNavigationBar = false;
  bool _debugMode = false;

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

  PreferencesController()
      : _preferencesSp = PreferencesStorage.instance {
    _loadPreferences();
    _loadPreferencesSetting();
  }

  bool get autoDetect => _autoDetect;
  String get selectedLanguage => _selectedLanguage;
  bool get persistChatSelection => _persistChatSelection;
  VibrationSettings get vibrationSettings => _vibrationSettings;
  bool get hideStatusBar => _hideStatusBar;
  bool get hideNavigationBar => _hideNavigationBar;
  bool get debugMode => _debugMode;

  void _loadPreferences() {
    final languageSetting = _preferencesSp.currentPreferences.languageSetting;
    _autoDetect = languageSetting.autoDetect;
    _selectedLanguage = languageSetting.languageCode;
    notifyListeners();
  }

  void _loadPreferencesSetting() {
    final appPrefs = _preferencesSp.currentPreferences;
    _persistChatSelection = appPrefs.persistChatSelection;
    _vibrationSettings = appPrefs.vibrationSettings;
    _hideStatusBar = appPrefs.hideStatusBar;
    _hideNavigationBar = appPrefs.hideNavigationBar;
    _debugMode = appPrefs.debugMode;
    notifyListeners();
  }

  Future<void> updatePreferencesSetting({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
  }) async {
    final newPrefs = _preferencesSp.currentPreferences.copyWith(
      persistChatSelection: persistChatSelection,
      vibrationSettings: vibrationSettings,
      hideStatusBar: hideStatusBar,
      hideNavigationBar: hideNavigationBar,
      debugMode: debugMode,
    );

    if (persistChatSelection != null) {
      _persistChatSelection = persistChatSelection;
    }
    if (vibrationSettings != null) _vibrationSettings = vibrationSettings;
    if (hideStatusBar != null) _hideStatusBar = hideStatusBar;
    if (hideNavigationBar != null) _hideNavigationBar = hideNavigationBar;
    if (debugMode != null) _debugMode = debugMode;

    notifyListeners();

    try {
      await _preferencesSp.updatePreferences(newPrefs);
    } catch (_) {
      // Revert changes on error
      _loadPreferencesSetting();
    }
  }

  Future<void> selectLanguage(String languageCode) async {
    try {
      _selectedLanguage = languageCode;
      _autoDetect = languageCode == 'auto';
      notifyListeners();

      if (languageCode == 'auto') {
        await _preferencesSp.setAutoDetectLanguage(true);
      } else {
        String? countryCode;
        if (languageCode.contains('_')) {
          final parts = languageCode.split('_');
          countryCode = parts[1];
          languageCode = parts[0];
        }

        await _preferencesSp.setLanguage(languageCode, countryCode: countryCode);
      }
    } catch (e) {
      _loadPreferences();
      rethrow;
    }
  }

  Locale getNewLocale() {
    final languageSetting = _preferencesSp.currentPreferences.languageSetting;
    Locale newLocale;

    if (languageSetting.autoDetect || languageSetting.languageCode == 'auto') {
      newLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (newLocale.languageCode == 'zh') {
        newLocale = const Locale('zh', 'CN');
      }
    } else {
      if (languageSetting.countryCode != null) {
        newLocale = Locale(languageSetting.languageCode, languageSetting.countryCode);
      } else {
        newLocale = Locale(languageSetting.languageCode);
      }
    }

    return newLocale;
  }

  String getCurrentLanguageName() {
    if (_autoDetect) {
      return 'Auto';
    }

    final selected = supportedLanguages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => supportedLanguages.first,
    );

    return selected['name'] as String;
  }
}
