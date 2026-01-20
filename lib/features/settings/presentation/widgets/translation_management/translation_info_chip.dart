import 'package:flutter/material.dart';

class TranslationInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const TranslationInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
