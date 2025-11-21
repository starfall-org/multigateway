import 'package:flutter/material.dart';
import 'providers_screen.dart';
import 'tts/tts_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: ListView(
        children: [
          _buildSettingsItem(
            context,
            Icons.smart_toy_outlined,
            'Providers',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProvidersScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(context, Icons.tune, 'Preferences'),
          _buildSettingsItem(
            context,
            Icons.notifications_outlined,
            'Notifications',
          ),
          _buildSettingsItem(
            context,
            Icons.record_voice_over_outlined,
            'TTS',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TTSScreen()),
              );
            },
          ),
          _buildSettingsItem(context, Icons.extension_outlined, 'MCP'),
          _buildSettingsItem(context, Icons.info_outline, 'Info'),
          _buildSettingsItem(context, Icons.system_update_outlined, 'Update'),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap:
          onTap ??
          () {
            // TODO: Navigate to specific settings section
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Navigate to $title')));
          },
    );
  }
}
