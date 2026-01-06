import 'package:flutter/material.dart';

import 'package:multigateway/app/config/routes.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            SettingsTile(
              icon: Icons.palette_outlined,
              title: tl('Appearance'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.appearance),
            ),
            SettingsTile(
              icon: Icons.tune,
              title: tl('Preferences'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.preferences),
            ),
            SettingsTile(
              icon: Icons.system_update_outlined,
              title: tl('Update'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.update),
            ),
            SettingsTile(
              icon: Icons.info_outline,
              title: tl('About'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.about),
            ),

            SettingsTile(
              icon: Icons.storage,
              title: tl('Data'),
              onTap: () => Navigator.pushNamed(context, AppRoutes.userdata),
            ),
          ],
        ),
      ),
    );
  }
}
