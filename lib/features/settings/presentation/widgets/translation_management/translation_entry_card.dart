import 'package:flutter/material.dart';
import 'package:multigateway/app/models/translation_cache_entry.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_language_block.dart';

class TranslationEntryCard extends StatelessWidget {
  final TranslationCacheEntry entry;
  final String targetLabel;
  final VoidCallback onEdit;

  const TranslationEntryCard({
    super.key,
    required this.entry,
    required this.targetLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslationLanguageBlock(
              label: 'English',
              value: entry.originalText,
              labelColor: colorScheme.primary,
            ),
            const SizedBox(height: 10),
            TranslationLanguageBlock(
              label: targetLabel,
              value: entry.translatedText,
              labelColor: colorScheme.tertiary,
              timestamp: entry.timestamp,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(tl('Edit translation')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
