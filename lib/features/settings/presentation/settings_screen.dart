import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/routes.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SettingsSectionHeader('settings.general_section'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.api,
                    title: 'providers.title'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.providers),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'settings.appearance.title'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.appearance),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.tune,
                    title: 'settings.preferences.select_language'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.preferences),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('settings.features_section'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.speaker_notes,
                    title: 'tts.title'.tr(),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.tts),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.extension_outlined,
                    title: 'mcp.title'.tr(),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mcp),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.generating_tokens,
                    title: 'ai_profiles.title'.tr(),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.aiProfiles),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('settings.about_section'.tr()),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.system_update_outlined,
                    title: 'settings.update.title'.tr(),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'settings.info.title'.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
