import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

class EditTranslationSheet extends StatelessWidget {
  final TextEditingController controller;
  final String languageLabel;

  const EditTranslationSheet({
    super.key,
    required this.controller,
    required this.languageLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tl('Edit translation'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${tl('Language')}: $languageLabel',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                labelText: tl('Translated text'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, controller.text),
                icon: const Icon(Icons.save_outlined),
                label: Text(tl('Save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
