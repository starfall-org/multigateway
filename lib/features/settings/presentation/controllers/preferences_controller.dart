import 'package:flutter/material.dart';
import 'package:multigateway/app/models/preferences_setting.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';

class PreferencesController extends ChangeNotifier {
  PreferencesStorage? _preferencesSp;

  bool _autoDetect = true;
  String _selectedLanguage = 'auto';
  bool _persistChatSelection = false;
  VibrationSettings _vibrationSettings = VibrationSettings.defaults();
  bool _hideStatusBar = false;
  bool _hideNavigationBar = false;
  bool _debugMode = false;
  bool _continueLastConversation = true;
  bool _isInitialized = false;

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
      _isInitialized = true;
      _loadPreferences();
      _loadPreferencesSetting();
    } catch (e) {
      // Ghi log lỗi nếu cần thiết
      debugPrint('Error initializing PreferencesController: $e');
    }
  }

  bool get autoDetect => _autoDetect;
  String get selectedLanguage => _selectedLanguage;
  bool get persistChatSelection => _persistChatSelection;
  VibrationSettings get vibrationSettings => _vibrationSettings;
  bool get hideStatusBar => _hideStatusBar;
  bool get hideNavigationBar => _hideNavigationBar;
  bool get debugMode => _debugMode;
  bool get continueLastConversation => _continueLastConversation;
  bool get isInitialized => _isInitialized;

  void _loadPreferences() {
    if (_preferencesSp == null) return;

    final languageSetting = _preferencesSp!.currentPreferences.languageSetting;
    _autoDetect = languageSetting.autoDetect;
    _selectedLanguage = languageSetting.languageCode;
    notifyListeners();
  }

  void _loadPreferencesSetting() {
    if (_preferencesSp == null) return;

    final appPrefs = _preferencesSp!.currentPreferences;
    _persistChatSelection = appPrefs.persistChatSelection;
    _vibrationSettings = appPrefs.vibrationSettings;
    _hideStatusBar = appPrefs.hideStatusBar;
    _hideNavigationBar = appPrefs.hideNavigationBar;
    _debugMode = appPrefs.debugMode;
    _continueLastConversation = appPrefs.continueLastConversation;
    notifyListeners();
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
      _persistChatSelection = persistChatSelection;
    }
    if (vibrationSettings != null) _vibrationSettings = vibrationSettings;
    if (hideStatusBar != null) _hideStatusBar = hideStatusBar;
    if (hideNavigationBar != null) _hideNavigationBar = hideNavigationBar;
    if (debugMode != null) _debugMode = debugMode;
    if (continueLastConversation != null) {
      _continueLastConversation = continueLastConversation;
    }

    notifyListeners();

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
      _selectedLanguage = languageCode;
      _autoDetect = languageCode == 'auto';
      notifyListeners();

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
