import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

class TranslationEmptyState extends StatelessWidget {
  final String languageLabel;

  const TranslationEmptyState({super.key, required this.languageLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tl('No translations cached for this language yet.'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tl(
                'Switch to another language or generate translations to start managing $languageLabel.',
              ),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class TranslationErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const TranslationErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(
            tl('Failed to load translations'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(tl('Retry')),
          ),
        ],
      ),
    );
  }
}
