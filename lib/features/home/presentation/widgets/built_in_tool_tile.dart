import 'package:flutter/material.dart';

/// Tile cho built-in tool
class BuiltInToolTile extends StatelessWidget {
  final String title;
  final String id;
  final IconData icon;
  final String subtitle;
  final bool isEnabled;
  final Function(bool) onChanged;

  const BuiltInToolTile({
    super.key,
    required this.title,
    required this.id,
    required this.icon,
    required this.subtitle,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: isEnabled,
      onChanged: onChanged,
    );
  }
}