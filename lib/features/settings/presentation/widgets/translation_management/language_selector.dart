import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/translation_management_controller.dart';

class LanguageSelector extends StatelessWidget {
  final List<LanguageOption> languages;
  final String selectedLanguage;
  final ValueChanged<String> onChanged;

  const LanguageSelector({
    super.key,
    required this.languages,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.translate_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                  children: [
                    TextSpan(text: tl('Select language')),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Tooltip(
                          message: tl(
                            'Defaults to your current language, unless it is English.',
                          ),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                menuMaxHeight: 320,
                itemHeight: 40,
                value: selectedLanguage,
                borderRadius: BorderRadius.circular(10),
                items: languages
                    .map(
                      (lang) => DropdownMenuItem(
                        value: lang.code,
                        child: Text(lang.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
