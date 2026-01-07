import 'package:flutter/material.dart';

import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/controllers/preferences_controller.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_card.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_section_header.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late PreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PreferencesController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Future<void> _selectLanguage(String languageCode) async {
    try {
      await _controller.selectLanguage(languageCode);

      if (mounted) {
        context.showSuccessSnackBar(
          tl('Language has been changed'),
          duration: const Duration(seconds: 1),
        );
      }
      _controller.getNewLocale();
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(tl('Failed to change language'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tl('Preferences'),
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
            SettingsSectionHeader(tl('General')),
            const SizedBox(height: 12),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.save_outlined,
                    title: tl('Persist selections'),
                    trailing: Switch(
                      value: _controller.persistChatSelection,
                      onChanged: (val) => _controller.updatePreferencesSetting(
                        persistChatSelection: val,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.vibration_outlined,
                    title: tl('Vibration'),
                    trailing: Switch(
                      value: _controller.vibrationSettings.enable,
                      onChanged: (val) => _controller.updatePreferencesSetting(
                        vibrationSettings: _controller.vibrationSettings
                            .copyWith(enable: val),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Display settings
            const SizedBox(height: 24),
            SettingsSectionHeader(tl('Display')),
            const SizedBox(height: 12),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.fullscreen_outlined,
                    title: tl('Hide Status Bar'),
                    trailing: Switch(
                      value: _controller.hideStatusBar,
                      onChanged: (val) => _controller.updatePreferencesSetting(
                        hideStatusBar: val,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.keyboard_hide_outlined,
                    title: tl('Hide Navigation Bar'),
                    trailing: Switch(
                      value: _controller.hideNavigationBar,
                      onChanged: (val) => _controller.updatePreferencesSetting(
                        hideNavigationBar: val,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Developer settings
            const SizedBox(height: 24),
            SettingsSectionHeader(tl('Developer')),
            const SizedBox(height: 12),
            SettingsCard(
              child: SettingsTile(
                icon: Icons.bug_report_outlined,
                title: tl('Debug Mode'),
                trailing: Switch(
                  value: _controller.debugMode,
                  onChanged: (val) =>
                      _controller.updatePreferencesSetting(debugMode: val),
                ),
              ),
            ),

            // Language section
            const SizedBox(height: 24),
            SettingsSectionHeader(tl('Languages')),
            const SizedBox(height: 12),
            SettingsCard(
              child: SettingsTile(
                icon: Icons.language_outlined,
                title: tl('Current Language'),
                subtitle: _controller.getCurrentLanguageName(),
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
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                children: _controller.supportedLanguages.map((language) {
                  final isSelected =
                      _controller.selectedLanguage == language['code'];
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
}
