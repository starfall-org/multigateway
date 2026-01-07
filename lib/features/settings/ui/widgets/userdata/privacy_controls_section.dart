import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section điều khiển quyền riêng tư
class PrivacyControlsSection extends StatelessWidget {
  final VoidCallback onAnonymizeTap;
  final VoidCallback onDeleteAllTap;

  const PrivacyControlsSection({
    super.key,
    required this.onAnonymizeTap,
    required this.onDeleteAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Privacy'),
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
                icon: Icons.visibility_off,
                title: 'Anonymize Data',
                subtitle: 'Remove personally identifiable information',
                onTap: onAnonymizeTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.delete_forever,
                title: 'Delete All Data',
                subtitle: 'Permanently delete all app data',
                onTap: onDeleteAllTap,
                isDestructive: true,
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
  final bool isDestructive;

  const _ControlTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}