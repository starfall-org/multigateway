import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section hiển thị các mục hỗ trợ
class SupportSection extends StatelessWidget {
  final VoidCallback onReportBugTap;
  final VoidCallback onRequestFeatureTap;
  final VoidCallback onHelpCenterTap;

  const SupportSection({
    super.key,
    required this.onReportBugTap,
    required this.onRequestFeatureTap,
    required this.onHelpCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Support'),
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
                icon: Icons.bug_report,
                title: 'Report Bug',
                subtitle: 'Send bug reports to us',
                onTap: onReportBugTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.lightbulb_outline,
                title: 'Feature Request',
                subtitle: 'Propose new features',
                onTap: onRequestFeatureTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Learn how to use the app',
                onTap: onHelpCenterTap,
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