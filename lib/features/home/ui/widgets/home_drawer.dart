import 'package:flutter/material.dart';

import '../../../../shared/translate/tl.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.onNavigateToChat,
    required this.onNavigateToAIProfiles,
    required this.onNavigateToProviders,
    required this.onNavigateToMCPServers,
    required this.onNavigateToSpeechServices,
    required this.onNavigateToSettings,
  });

  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToAIProfiles;
  final VoidCallback onNavigateToProviders;
  final VoidCallback onNavigateToMCPServers;
  final VoidCallback onNavigateToSpeechServices;
  final VoidCallback onNavigateToSettings;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: true,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('AI Gateway'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tl('App Navigation'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              onTap: onNavigateToChat,
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              title: 'AI Profiles',
              onTap: onNavigateToAIProfiles,
            ),
            _DrawerItem(
              icon: Icons.cloud_outlined,
              title: 'Providers',
              onTap: onNavigateToProviders,
            ),
            _DrawerItem(
              icon: Icons.extension_outlined,
              title: 'MCP Servers',
              onTap: onNavigateToMCPServers,
            ),
            _DrawerItem(
              icon: Icons.record_voice_over,
              title: 'Speech Services',
              onTap: onNavigateToSpeechServices,
            ),
            const Divider(),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: onNavigateToSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}


