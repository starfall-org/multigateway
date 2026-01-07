import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section quản lý dữ liệu
class DataManagementSection extends StatelessWidget {
  final VoidCallback onBackupTap;
  final VoidCallback onRestoreTap;
  final VoidCallback onExportTap;

  const DataManagementSection({
    super.key,
    required this.onBackupTap,
    required this.onRestoreTap,
    required this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Data Management'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _ControlTile(
                icon: Icons.backup,
                title: 'Backup Data',
                subtitle: 'Create backup of app data',
                onTap: onBackupTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.restore,
                title: 'Restore Data',
                subtitle: 'Restore from backup',
                onTap: onRestoreTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.import_export,
                title: 'Export Data',
                subtitle: 'Export data to file',
                onTap: onExportTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget tile điều khiển
class _ControlTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ControlTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}