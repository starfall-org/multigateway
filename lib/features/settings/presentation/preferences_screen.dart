import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/app_preferences.dart';
import '../../../core/storage/language_repository.dart';
import '../../../core/storage/app_preferences_repository.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_card.dart';

// TODO: move logic to viewmodel
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late LanguageRepository _languageRepository;
  bool _autoDetectLanguage = true;
  String _selectedLanguage = 'auto';

  // App preferences
  bool _persistChatSelection = false;
  VibrationSettings _vibrationSettings = VibrationSettings.defaults();
  bool _hideStatusBar = false;
  bool _hideNavigationBar = false;
  bool _debugMode = false;

  final List<Map<String, dynamic>> _supportedLanguages = [
    {'code': 'auto', 'name': 'settings.preferences.auto_detect', 'flag': ''},
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

  @override
  void initState() {
    super.initState();
    _languageRepository = LanguageRepository.instance;
    _loadPreferences();
    _loadAppPreferences();
  }

  void _loadPreferences() {
    final preferences = _languageRepository.currentPreferences;
    setState(() {
      _autoDetectLanguage = preferences.autoDetectLanguage;
      _selectedLanguage = preferences.languageCode;
    });
  }

  void _loadAppPreferences() {
    final appPrefs = AppPreferencesRepository.instance.currentPreferences;
    setState(() {
      _persistChatSelection = appPrefs.persistChatSelection;
      _vibrationSettings = appPrefs.vibrationSettings;
      _hideStatusBar = appPrefs.hideStatusBar;
      _hideNavigationBar = appPrefs.hideNavigationBar;
      _debugMode = appPrefs.debugMode;
    });
  }

  Future<void> _updateAppPreferences({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
  }) async {
    final newPrefs = AppPreferencesRepository.instance.currentPreferences
        .copyWith(
          persistChatSelection: persistChatSelection,
          vibrationSettings: vibrationSettings,
          hideStatusBar: hideStatusBar,
          hideNavigationBar: hideNavigationBar,
          debugMode: debugMode,
        );

    setState(() {
      if (persistChatSelection != null) {
        _persistChatSelection = persistChatSelection;
      }
      if (vibrationSettings != null) _vibrationSettings = vibrationSettings;
      if (hideStatusBar != null) _hideStatusBar = hideStatusBar;
      if (hideNavigationBar != null) _hideNavigationBar = hideNavigationBar;
      if (debugMode != null) _debugMode = debugMode;
    });

    try {
      await AppPreferencesRepository.instance.updatePreferences(newPrefs);
    } catch (_) {
      // Revert changes on error
      _loadAppPreferences();
    }
  }

  Future<void> _toggleAutoDetect(bool value) async {
    try {
      setState(() {
        _autoDetectLanguage = value;
        if (value) {
          _selectedLanguage = 'auto';
        }
      });

      await _languageRepository.setAutoDetect(value);

      if (value) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.preferences.auto_detect_enabled'.tr()),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        _restartApp();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.preferences.auto_detect_error'.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        _loadPreferences();
      }
    }
  }

  Future<void> _selectLanguage(String languageCode) async {
    try {
      setState(() {
        _selectedLanguage = languageCode;
        _autoDetectLanguage = false;
      });

      String? countryCode;
      if (languageCode.contains('_')) {
        final parts = languageCode.split('_');
        countryCode = parts[1];
        languageCode = parts[0];
      }

      await _languageRepository.setLanguage(
        languageCode,
        countryCode: countryCode,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.preferences.language_changed'.tr()),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      _restartApp();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.preferences.language_change_error'.tr()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        _loadPreferences();
      }
    }
  }

  void _restartApp() {
    final preferences = _languageRepository.currentPreferences;
    Locale newLocale;

    if (preferences.autoDetectLanguage || preferences.languageCode == 'auto') {
      newLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (newLocale.languageCode == 'zh') {
        newLocale = const Locale('zh', 'CN');
      }
    } else {
      if (preferences.countryCode != null) {
        newLocale = Locale(preferences.languageCode, preferences.countryCode);
      } else {
        newLocale = Locale(preferences.languageCode);
      }
    }

    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.preferences.title'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: ListView(
        children: [
          // General settings
          SettingsSectionHeader('settings.preferences.general'.tr()),
          const SizedBox(height: 12),
          SettingsCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.save_outlined,
                  title: 'settings.preferences.persist_chat_selection'.tr(),
                  trailing: Switch(
                    value: _persistChatSelection,
                    onChanged: (val) =>
                        _updateAppPreferences(persistChatSelection: val),
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SettingsTile(
                  icon: Icons.vibration_outlined,
                  title: 'settings.preferences.vibration_enabled'.tr(),
                  trailing: Switch(
                    value: _vibrationSettings.enable,
                    onChanged: (val) => _updateAppPreferences(
                      vibrationSettings: _vibrationSettings.copyWith(
                        enable: val,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display settings
          const SizedBox(height: 24),
          SettingsSectionHeader('settings.preferences.display'.tr()),
          const SizedBox(height: 12),
          SettingsCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.fullscreen_outlined,
                  title: 'settings.preferences.hide_status_bar'.tr(),
                  trailing: Switch(
                    value: _hideStatusBar,
                    onChanged: (val) =>
                        _updateAppPreferences(hideStatusBar: val),
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SettingsTile(
                  icon: Icons.keyboard_hide_outlined,
                  title: 'settings.preferences.hide_navigation_bar'.tr(),
                  trailing: Switch(
                    value: _hideNavigationBar,
                    onChanged: (val) =>
                        _updateAppPreferences(hideNavigationBar: val),
                  ),
                ),
              ],
            ),
          ),

          // Developer settings
          const SizedBox(height: 24),
          SettingsSectionHeader('settings.preferences.developer'.tr()),
          const SizedBox(height: 12),
          SettingsCard(
            child: SettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'settings.preferences.debug_mode'.tr(),
              trailing: Switch(
                value: _debugMode,
                onChanged: (val) => _updateAppPreferences(debugMode: val),
              ),
            ),
          ),

          // Language section
          const SizedBox(height: 24),
          SettingsSectionHeader('settings.preferences.select_language'.tr()),
          const SizedBox(height: 12),
          SettingsCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'settings.preferences.auto_detect'.tr(),
                  trailing: Switch(
                    value: _autoDetectLanguage,
                    onChanged: _toggleAutoDetect,
                  ),
                ),
                if (!_autoDetectLanguage) ...[
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.translate_outlined,
                    title: 'settings.preferences.current_language'.tr(),
                    subtitle: _getCurrentLanguageName(),
                    onTap: () => _showLanguagePicker(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'settings.preferences.select_language'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _supportedLanguages
                    .where((lang) => lang['code'] != 'auto')
                    .map((language) {
                      final isSelected = _selectedLanguage == language['code'];
                      return ListTile(
                        leading: Text(
                          language['flag'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(language['name'].tr()),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _selectLanguage(language['code']);
                        },
                      );
                    })
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageName() {
    if (_autoDetectLanguage) {
      return 'settings.preferences.auto_detect'.tr();
    }

    final selected = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _supportedLanguages.first,
    );

    return selected['name'].tr();
  }
}
