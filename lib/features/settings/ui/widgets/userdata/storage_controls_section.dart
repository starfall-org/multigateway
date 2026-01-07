import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section điều khiển lưu trữ
class StorageControlsSection extends StatelessWidget {
  final VoidCallback onCleanCacheTap;
  final VoidCallback onManageFilesTap;

  const StorageControlsSection({
    super.key,
    required this.onCleanCacheTap,
    required this.onManageFilesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Storage Controls'),
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
                icon: Icons.cleaning_services,
                title: 'Clean Cache',
                subtitle: 'Clear temporary cache files',
                onTap: onCleanCacheTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.folder_open,
                title: 'Manage Files',
                subtitle: 'View and manage saved files',
                onTap: onManageFilesTap,
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