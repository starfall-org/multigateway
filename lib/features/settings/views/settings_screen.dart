import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../screens/settings_screen/providers_screen.dart';
import '../../screens/settings_screen/tts_screen.dart';
import 'appearance_screen.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: ListView(
        children: [
          SettingsTile(
            icon: Icons.smart_toy_outlined,
            title: 'settings.providers'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProvidersScreen(),
                ),
              );
            },
          ),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: 'settings.appearance'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              );
            },
          ),
          SettingsTile(icon: Icons.tune, title: 'settings.preferences'.tr()),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'settings.notifications'.tr(),
          ),
          SettingsTile(
            icon: Icons.record_voice_over_outlined,
            title: 'settings.tts'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TTSScreen()),
              );
            },
          ),
          SettingsTile(
            icon: Icons.extension_outlined,
            title: 'settings.mcp'.tr(),
          ),
          SettingsTile(icon: Icons.info_outline, title: 'settings.info'.tr()),
          SettingsTile(
            icon: Icons.system_update_outlined,
            title: 'settings.update'.tr(),
          ),
        ],
      ),
    );
  }
}
