import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_cache_entry.dart';
import 'shared_prefs_base.dart';

class TranslationCacheStorage
    extends SharedPreferencesBase<TranslationCacheEntry> {
  static const String _prefix = 'translation_cache';

  TranslationCacheStorage(super.prefs);

  /// Reactive stream of cache entries; emits immediately and on each change.
  Stream<List<TranslationCacheEntry>> get entriesStream => itemsStream;

  static TranslationCacheStorage? _instance;

  static Future<TranslationCacheStorage> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = TranslationCacheStorage(prefs);
    return _instance!;
  }

  static TranslationCacheStorage get instance {
    if (_instance == null) {
      throw Exception(
        'TranslationCacheStorage not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(TranslationCacheEntry item) => item.cacheKey;

  @override
  Map<String, dynamic> serializeToFields(TranslationCacheEntry item) {
    return item.toJson();
  }

  @override
  TranslationCacheEntry deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return TranslationCacheEntry.fromJson(fields);
  }

  /// Lưu bản dịch vào cache
  Future<void> saveTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final entry = TranslationCacheEntry(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
    );

    await saveItem(entry);
  }

  /// Tìm bản dịch trong cache
  TranslationCacheEntry? getCachedTranslation({
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final cacheKey = '${sourceLanguage}_${targetLanguage}_${originalText.hashCode}';
    return getItem(cacheKey);
  }

  /// Xóa tất cả cache
  Future<void> clearCache() async {
    await clear();
  }

  /// Lấy thống kê cache
  Map<String, dynamic> getCacheStats() {
    final items = getItems();

    return {
      'totalEntries': items.length,
    };
  }
}