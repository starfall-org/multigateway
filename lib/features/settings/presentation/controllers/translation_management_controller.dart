import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:multigateway/app/models/translation_cache_entry.dart';
import 'package:multigateway/app/storage/translation_cache_storage.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:signals/signals.dart';

class LanguageOption {
  final String code;
  final String label;

  const LanguageOption({
    required this.code,
    required this.label,
  });
}

/// Controller quản lý danh sách bản dịch và chọn ngôn ngữ để chỉnh sửa
class TranslationManagementController {
  TranslationCacheStorage? _cacheStorage;
  StreamSubscription<List<TranslationCacheEntry>>? _subscription;
  List<TranslationCacheEntry> _allEntries = [];

  final isLoading = signal<bool>(true);
  final selectedLanguage = signal<String>('en');
  final translations = signal<List<TranslationCacheEntry>>([]);
  final searchQuery = signal<String>('');
  final lastError = signal<String?>(null);

  final List<LanguageOption> languageOptions = [
    const LanguageOption(code: 'en', label: 'English'),
    const LanguageOption(code: 'vi', label: 'Vietnamese'),
    const LanguageOption(code: 'fr', label: 'French'),
    const LanguageOption(code: 'de', label: 'German'),
    const LanguageOption(code: 'ja', label: 'Japanese'),
    const LanguageOption(code: 'zh-CN', label: 'Chinese (Simplified)'),
    const LanguageOption(code: 'zh-TW', label: 'Chinese (Traditional)'),
    const LanguageOption(code: 'ko', label: 'Korean'),
    const LanguageOption(code: 'es', label: 'Spanish'),
  ];

  Future<void> initialize() async {
    isLoading.value = true;
    lastError.value = null;
    _subscription?.cancel();
    _cacheStorage = await TranslationCacheStorage.init();
    final initialLanguage = await _resolveInitialLanguage();
    _ensureLanguageOption(initialLanguage);
    selectedLanguage.value = initialLanguage;

    _subscription = _cacheStorage!.entriesStream.listen(_handleEntries);
    _handleEntries(_cacheStorage!.getItems());

    isLoading.value = false;
  }

  Future<String> _resolveInitialLanguage() async {
    try {
      final target = await TranslationManager.instance.getTargetLanguage();
      final normalized = _normalizeCode(target);

      if (normalized != 'en' && normalized.isNotEmpty) {
        return normalized;
      }
    } catch (_) {
      // Ignore errors and fall back
    }
    return _firstNonEnglish();
  }

  String _firstNonEnglish() {
    return languageOptions.firstWhere((lang) => lang.code != 'en').code;
  }

  void _handleEntries(List<TranslationCacheEntry> entries) {
    _allEntries = entries;
    for (final entry in entries) {
      _ensureLanguageOption(entry.targetLanguage);
    }
    _refreshFiltered();
  }

  void changeLanguage(String languageCode) {
    final normalized = _normalizeCode(languageCode);
    _ensureLanguageOption(normalized);
    selectedLanguage.value = normalized;
    _refreshFiltered();
  }

  void updateSearch(String query) {
    searchQuery.value = query.trim();
    _refreshFiltered();
  }

  void _refreshFiltered() {
    final current = selectedLanguage.value;
    final query = searchQuery.value.toLowerCase();
    final filtered = _allEntries
        .where(
          (entry) => _normalizeCode(entry.targetLanguage) == current,
        )
        .where((entry) {
          if (query.isEmpty) return true;
          return entry.originalText.toLowerCase().contains(query) ||
              entry.translatedText.toLowerCase().contains(query);
        })
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    translations.value = filtered;
  }

  Future<void> updateTranslation(
    TranslationCacheEntry entry,
    String updatedText,
  ) async {
    if (_cacheStorage == null) return;
    final updatedEntry = entry.copyWith(
      translatedText: updatedText,
      timestamp: DateTime.now(),
    );
    await _cacheStorage!.saveItem(updatedEntry);
    await TranslationManager.instance.reloadCache();
  }

  Future<bool> saveEditedTranslation(
    TranslationCacheEntry entry,
    String newText,
  ) async {
    final trimmed = newText.trim();
    if (trimmed.isEmpty) {
      lastError.value = tl('Translation cannot be empty');
      return false;
    }
    await updateTranslation(entry, trimmed);
    lastError.value = null;
    return true;
  }

  String languageLabel(String code) {
    final normalized = _normalizeCode(code);
    final option = languageOptions.firstWhere(
      (lang) => lang.code == normalized,
      orElse: () => LanguageOption(
        code: normalized,
        label: normalized.toUpperCase(),
      ),
    );
    return option.label;
  }

  void _ensureLanguageOption(String code) {
    final normalized = _normalizeCode(code);
    final exists = languageOptions.any((lang) => lang.code == normalized);
    if (!exists && normalized.isNotEmpty) {
      languageOptions.add(
        LanguageOption(code: normalized, label: normalized.toUpperCase()),
      );
    }
  }

  String _normalizeCode(String code) {
    if (code.isEmpty) return code;
    final sanitized = code.replaceAll('_', '-');
    final parts = sanitized.split('-');
    if (parts.length == 2) {
      return '${parts[0].toLowerCase()}-${parts[1].toUpperCase()}';
    }
    return sanitized.toLowerCase();
  }

  void dispose() {
    isLoading.dispose();
    selectedLanguage.dispose();
    searchQuery.dispose();
    translations.dispose();
    lastError.dispose();
    _subscription?.cancel();
  }
}

class TranslationManagementControllerScope extends StatefulWidget {
  final Widget child;
  const TranslationManagementControllerScope({super.key, required this.child});

  @override
  State<TranslationManagementControllerScope> createState() =>
      _TranslationManagementControllerScopeState();
}

class _TranslationManagementControllerScopeState
    extends State<TranslationManagementControllerScope> {
  late final TranslationManagementController _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = TranslationManagementController();
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TranslationManagementControllerProvider(
      controller: _controller,
      initializationFuture: _initFuture,
      child: widget.child,
      onReinitialize: () {
        setState(() {
          _initFuture = _controller.initialize();
        });
      },
    );
  }
}

class TranslationManagementControllerProvider extends InheritedWidget {
  final TranslationManagementController controller;
  final Future<void> initializationFuture;
  final VoidCallback onReinitialize;

  const TranslationManagementControllerProvider({
    super.key,
    required this.controller,
    required this.initializationFuture,
    required this.onReinitialize,
    required super.child,
  });

  static TranslationManagementController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<
            TranslationManagementControllerProvider>();
    assert(provider != null, 'TranslationManagementControllerProvider not found');
    return provider!.controller;
  }

  static Future<void> initializationFutureOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<
            TranslationManagementControllerProvider>();
    assert(provider != null, 'TranslationManagementControllerProvider not found');
    return provider!.initializationFuture;
  }

  static void reinitialize(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<
            TranslationManagementControllerProvider>();
    assert(provider != null, 'TranslationManagementControllerProvider not found');
    provider!.onReinitialize();
  }

  @override
  bool updateShouldNotify(
    covariant TranslationManagementControllerProvider oldWidget,
  ) {
    return controller != oldWidget.controller ||
        initializationFuture != oldWidget.initializationFuture;
  }
}
