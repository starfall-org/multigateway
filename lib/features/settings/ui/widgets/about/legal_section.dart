import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section hiển thị các mục pháp lý
class LegalSection extends StatelessWidget {
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onTermsOfServiceTap;
  final VoidCallback onOpenSourceTap;

  const LegalSection({
    super.key,
    required this.onPrivacyPolicyTap,
    required this.onTermsOfServiceTap,
    required this.onOpenSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Legal'),
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
                icon: Icons.description,
                title: 'Privacy Policy',
                subtitle: 'View data privacy policy',
                onTap: onPrivacyPolicyTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.rule,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: onTermsOfServiceTap,
              ),
              const Divider(height: 1),
              _ControlTile(
                icon: Icons.info_outline,
                title: 'Public Limit License',
                subtitle: 'Public source license information',
                onTap: onOpenSourceTap,
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