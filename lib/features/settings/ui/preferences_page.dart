import 'package:flutter/material.dart';

import '../../../core/models/app_preferences.dart';
import '../../../core/storage/language_repository.dart';
import '../../../core/storage/app_preferences_repository.dart';
import '../../../core/translate.dart';
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
  late LanguageSp _LanguageSp;
  bool _autoDetectLanguage = true;
  String _selectedLanguage = 'auto';

  // App preferences
  bool _persistChatSelection = false;
  VibrationSettings _vibrationSettings = VibrationSettings.defaults();
  bool _hideStatusBar = false;
  bool _hideNavigationBar = false;
  bool _debugMode = false;

  final List<Map<String, dynamic>> _supportedLanguages = [
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

  @override
  void initState() {
    super.initState();
    _LanguageSp = LanguageSp.instance;
    _loadPreferences();
    _loadPreferencesSetting();
  }

  void _loadPreferences() {
    final preferences = _LanguageSp.currentPreferences;
    setState(() {
      _autoDetectLanguage = preferences.autoDetectLanguage;
      _selectedLanguage = preferences.languageCode;
    });
  }

  void _loadPreferencesSetting() {
    final appPrefs = PreferencesSp.instance.currentPreferences;
    setState(() {
      _persistChatSelection = appPrefs.persistChatSelection;
      _vibrationSettings = appPrefs.vibrationSettings;
      _hideStatusBar = appPrefs.hideStatusBar;
      _hideNavigationBar = appPrefs.hideNavigationBar;
      _debugMode = appPrefs.debugMode;
    });
  }

  Future<void> _updatePreferencesSetting({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
  }) async {
    final newPrefs = PreferencesSp.instance.currentPreferences
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
      await PreferencesSp.instance.updatePreferences(newPrefs);
    } catch (_) {
      // Revert changes on error
      _loadPreferencesSetting();
    }
  }

  Future<void> _selectLanguage(String languageCode) async {
    try {
      setState(() {
        _selectedLanguage = languageCode;
        _autoDetectLanguage = languageCode == 'auto';
      });

      if (languageCode == 'auto') {
        await _LanguageSp.setAutoDetect(true);
      } else {
        String? countryCode;
        if (languageCode.contains('_')) {
          final parts = languageCode.split('_');
          countryCode = parts[1];
          languageCode = parts[0];
        }

        await _LanguageSp.setLanguage(
          languageCode,
          countryCode: countryCode,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tl('Language has been changed')),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      _restartApp();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tl('Failed to change language')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        _loadPreferences();
      }
    }
  }

  void _restartApp() {
    final preferences = _LanguageSp.currentPreferences;
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

    // Note: Locale setting is handled by the language repository
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tl('settings.preferences.title'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          children: [
          // General settings
          SettingsSectionHeader('General'),
          const SizedBox(height: 12),
          SettingsCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.save_outlined,
                  title: 'Persist selections',
                  trailing: Switch(
                    value: _persistChatSelection,
                    onChanged: (val) =>
                        _updatePreferencesSetting(persistChatSelection: val),
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SettingsTile(
                  icon: Icons.vibration_outlined,
                  title: 'Vibration',
                  trailing: Switch(
                    value: _vibrationSettings.enable,
                    onChanged: (val) => _updatePreferencesSetting(
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
          SettingsSectionHeader('Display'),
          const SizedBox(height: 12),
          SettingsCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.fullscreen_outlined,
                  title: 'Hide Status Bar',
                  trailing: Switch(
                    value: _hideStatusBar,
                    onChanged: (val) =>
                        _updatePreferencesSetting(hideStatusBar: val),
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SettingsTile(
                  icon: Icons.keyboard_hide_outlined,
                  title: 'Hide Navigation Bar',
                  trailing: Switch(
                    value: _hideNavigationBar,
                    onChanged: (val) =>
                        _updatePreferencesSetting(hideNavigationBar: val),
                  ),
                ),
              ],
            ),
          ),

          // Developer settings
          const SizedBox(height: 24),
          SettingsSectionHeader('Developer'),
          const SizedBox(height: 12),
          SettingsCard(
            child: SettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'Debug Mode',
              trailing: Switch(
                value: _debugMode,
                onChanged: (val) => _updatePreferencesSetting(debugMode: val),
              ),
            ),
          ),

          // Language section
          const SizedBox(height: 24),
          SettingsSectionHeader('Languages'),
          const SizedBox(height: 12),
          SettingsCard(
            child: SettingsTile(
              icon: Icons.language_outlined,
              title: 'Current Language',
              subtitle: _getCurrentLanguageName(),
              onTap: () => _showLanguagePicker(),
            ),
          ),
        ],
        ),
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
                tl('Languages'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _supportedLanguages.map((language) {
                  final isSelected = _selectedLanguage == language['code'];
                  return ListTile(
                    leading: Text(
                      language['flag'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(language['name'] as String),
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageName() {
    if (_autoDetectLanguage) {
      return 'Auto';
    }

    final selected = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _supportedLanguages.first,
    );

    return selected['name'] as String;
  }
}
