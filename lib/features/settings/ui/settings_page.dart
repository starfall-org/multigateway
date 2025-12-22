import 'package:flutter/material.dart';

import '../../../sys/routes.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

import '../../../core/translate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tl('Settings'),
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
            SettingsSectionHeader('General'),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.api,
                    title: 'Providers',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.providers),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.appearance),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.tune,
                    title: 'Languages',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.preferences),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('Online Features'),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.speaker_notes,
                    title: 'Speech Services',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.tts),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.extension_outlined,
                    title: 'MCP Servers',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.mcp),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.generating_tokens,
                    title: 'ai_profiles.title',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.aiProfiles),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('About'),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.system_update_outlined,
                    title: 'Update',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.update),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSectionHeader('Data'),
            SettingsCard(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.storage,
                    title: 'Data Controls',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.datacontrols),
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
