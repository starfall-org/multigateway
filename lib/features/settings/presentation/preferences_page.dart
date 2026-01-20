import 'package:flutter/material.dart';

import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/preferences_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_tile.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals/signals_flutter.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Preferences'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('General preferences'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Watch((context) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SettingsSectionHeader(tl('General')),
              const SizedBox(height: 8),
              SettingsCard(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.chat_outlined,
                      title: tl('Continue last conversation'),
                      subtitle: tl('Open last conversation when app starts'),
                      trailing: Switch(
                        value: _controller.continueLastConversation.value,
                        onChanged: (val) =>
                            _controller.updatePreferencesSetting(
                              continueLastConversation: val,
                            ),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    SettingsTile(
                      icon: Icons.save_outlined,
                      title: tl('Persist selections'),
                      trailing: Switch(
                        value: _controller.persistChatSelection.value,
                        onChanged: (val) =>
                            _controller.updatePreferencesSetting(
                              persistChatSelection: val,
                            ),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    SettingsTile(
                      icon: Icons.vibration_outlined,
                      title: tl('Vibration'),
                      trailing: Switch(
                        value: _controller.vibrationSettings.value.enable,
                        onChanged: (val) =>
                            _controller.updatePreferencesSetting(
                              vibrationSettings: _controller
                                  .vibrationSettings
                                  .value
                                  .copyWith(enable: val),
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SettingsSectionHeader(tl('Display')),
              const SizedBox(height: 8),
              SettingsCard(
                child: Column(
                  children: [
                    SettingsTile(
                      icon: Icons.fullscreen_outlined,
                      title: tl('Hide Status Bar'),
                      trailing: Switch(
                        value: _controller.hideStatusBar.value,
                        onChanged: (val) => _controller
                            .updatePreferencesSetting(hideStatusBar: val),
                      ),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 16),
                    SettingsTile(
                      icon: Icons.keyboard_hide_outlined,
                      title: tl('Hide Navigation Bar'),
                      trailing: Switch(
                        value: _controller.hideNavigationBar.value,
                        onChanged: (val) => _controller
                            .updatePreferencesSetting(hideNavigationBar: val),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SettingsSectionHeader(tl('Developer')),
              const SizedBox(height: 8),
              SettingsCard(
                child: SettingsTile(
                  icon: Icons.bug_report_outlined,
                  title: tl('Debug Mode'),
                  trailing: Switch(
                    value: _controller.debugMode.value,
                    onChanged: (val) =>
                        _controller.updatePreferencesSetting(debugMode: val),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SettingsSectionHeader(tl('Languages')),
              const SizedBox(height: 8),
              SettingsCard(
                child: SettingsTile(
                  icon: Icons.language_outlined,
                  title: tl('Current Language'),
                  subtitle: _controller.getCurrentLanguageName(),
                  onTap: () => _showLanguagePicker(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showLanguagePicker() {
    CustomBottomSheet.show(
      context,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              tl('Languages'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Expanded(
            child: Watch((context) {
              return ListView(
                controller: scrollController,
                children: _controller.supportedLanguages.map((language) {
                  final isSelected =
                      _controller.selectedLanguage.value == language['code'];
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
              );
            }),
          ),
        ],
      ),
    );
  }
}
