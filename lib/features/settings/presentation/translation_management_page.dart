import 'package:flutter/material.dart';
import 'package:multigateway/app/models/translation_cache_entry.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/translation_management_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/language_selector.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_edit_sheet.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_entry_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_info_chip.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_search_field.dart';
import 'package:multigateway/features/settings/presentation/widgets/translation_management/translation_states.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';
import 'package:signals/signals_flutter.dart';

class TranslationManagementPage extends StatelessWidget {
  const TranslationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TranslationManagementControllerScope(
      child: const _TranslationManagementView(),
    );
  }
}

class _TranslationManagementView extends StatefulWidget {
  const _TranslationManagementView();

  @override
  State<_TranslationManagementView> createState() =>
      _TranslationManagementViewState();
}

class _TranslationManagementViewState
    extends State<_TranslationManagementView> {
  late final TextEditingController _searchController;
  late TranslationManagementController _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = TranslationManagementControllerProvider.of(context);
    _initFuture ??=
        TranslationManagementControllerProvider.initializationFutureOf(
          context,
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Translations'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Compare translations with English'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<void>(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return TranslationErrorState(onRetry: _handleRetry);
            }
            return Watch((context) {
              final selectedLanguage = _controller.selectedLanguage.value;
              final translations = _controller.translations.value;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LanguageSelector(
                      languages: _controller.languageOptions,
                      selectedLanguage: selectedLanguage,
                      onChanged: _controller.changeLanguage,
                    ),
                    const SizedBox(height: 12),
                    TranslationSearchField(
                      controller: _searchController,
                      onChanged: _controller.updateSearch,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tl(
                        'Review cached translations side-by-side with English and edit them to keep the app wording accurate.',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TranslationInfoChip(
                          icon: Icons.flag_outlined,
                          label: tl('Editing'),
                          value: _controller.languageLabel(selectedLanguage),
                        ),
                        const SizedBox(width: 8),
                        TranslationInfoChip(
                          icon: Icons.library_books_outlined,
                          label: tl('Entries'),
                          value: translations.length.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: translations.isEmpty
                          ? TranslationEmptyState(
                              languageLabel: _controller.languageLabel(
                                selectedLanguage,
                              ),
                            )
                          : ListView.separated(
                              itemCount: translations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final entry = translations[index];
                                return TranslationEntryCard(
                                  entry: entry,
                                  targetLabel: _controller.languageLabel(
                                    selectedLanguage,
                                  ),
                                  onEdit: () => _openEditSheet(entry),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _openEditSheet(TranslationCacheEntry entry) async {
    final textController = TextEditingController(text: entry.translatedText);
    final result = await CustomBottomSheet.show<String>(
      context,
      padding: const EdgeInsets.all(12),
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: EditTranslationSheet(
          controller: textController,
          languageLabel: _controller.languageLabel(
            _controller.selectedLanguage.value,
          ),
        ),
      ),
    );
    textController.dispose();

    if (result != null && result.trim().isNotEmpty && mounted) {
      final success = await _controller.saveEditedTranslation(entry, result);
      if (!mounted) return;
      if (!success) {
        final message =
            _controller.lastError.value ?? tl('Could not update translation');
        context.showErrorSnackBar(message);
        return;
      }
      context.showSuccessSnackBar(tl('Translation updated'));
    }
  }

  void _handleRetry() {
    TranslationManagementControllerProvider.reinitialize(context);
    setState(() {
      _initFuture =
          TranslationManagementControllerProvider.initializationFutureOf(
        context,
      );
    });
  }
}
