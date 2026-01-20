import 'package:flutter/material.dart';

class TranslationLanguageBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final DateTime? timestamp;

  const TranslationLanguageBlock({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (timestamp != null)
              Text(
                _formatTimestamp(timestamp!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime time) {
    final local = time.toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}
