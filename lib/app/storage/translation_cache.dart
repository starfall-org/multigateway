import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_cache_entry.dart';
import 'shared_prefs_base.dart';

class TranslationCacheRepository
    extends SharedPreferencesBase<TranslationCacheEntry> {
  static const String _prefix = 'translation_cache';
  static const int _maxCacheSize = 1000;
  static const Duration _cacheExpiration = Duration(days: 7);

  TranslationCacheRepository(super.prefs);

  /// Reactive stream of cache entries; emits immediately and on each change.
  Stream<List<TranslationCacheEntry>> get entriesStream => itemsStream;

  static TranslationCacheRepository? _instance;

  static Future<TranslationCacheRepository> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = TranslationCacheRepository(prefs);
    return _instance!;
  }

  static TranslationCacheRepository get instance {
    if (_instance == null) {
      throw Exception(
        'TranslationCacheRepository not initialized. Call init() first.',
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
    try {
      final entry = TranslationCacheEntry(
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        timestamp: DateTime.now(),
      );

      await saveItem(entry);

      // Kiểm tra và dọn dẹp cache nếu quá lớn
      await _cleanupCacheIfNeeded();
    } catch (e) {
      // Log error but don't throw - cache failure shouldn't break translation
      debugPrint('Failed to save translation to cache: $e');
    }
  }

  /// Tìm bản dịch trong cache
  TranslationCacheEntry? getCachedTranslation({
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    try {
      final items = getItems();
      final cacheKey =
          '${sourceLanguage}_${targetLanguage}_${originalText.hashCode}';

      for (final item in items) {
        if (item.cacheKey == cacheKey) {
          // Kiểm tra xem cache có còn hợp lệ không
          if (DateTime.now().difference(item.timestamp) < _cacheExpiration) {
            return item;
          } else {
            // Xóa cache hết hạn
            deleteItem(item.cacheKey);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get cached translation: $e');
      return null;
    }
  }

  /// Xóa tất cả cache
  Future<void> clearCache() async {
    try {
      final items = getItems();
      for (final item in items) {
        await deleteItem(item.cacheKey);
      }
    } catch (e) {
      debugPrint('Failed to clear translation cache: $e');
    }
  }

  /// Dọn dẹp cache nếu quá lớn
  Future<void> _cleanupCacheIfNeeded() async {
    try {
      final items = getItems();
      if (items.length > _maxCacheSize) {
        // Sắp xếp theo thời gian và xóa những cái cũ nhất
        items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final toDelete = items.take(items.length - _maxCacheSize ~/ 2);

        for (final item in toDelete) {
          await deleteItem(item.cacheKey);
        }
      }

      // Xóa các cache hết hạn
      final now = DateTime.now();
      final expiredItems = items
          .where((item) => now.difference(item.timestamp) >= _cacheExpiration)
          .toList();

      for (final item in expiredItems) {
        await deleteItem(item.cacheKey);
      }
    } catch (e) {
      debugPrint('Failed to cleanup translation cache: $e');
    }
  }

  /// Lấy thống kê cache
  Map<String, dynamic> getCacheStats() {
    try {
      final items = getItems();
      final now = DateTime.now();
      final validItems = items
          .where((item) => now.difference(item.timestamp) < _cacheExpiration)
          .toList();

      return {
        'totalEntries': items.length,
        'validEntries': validItems.length,
        'expiredEntries': items.length - validItems.length,
        'maxCacheSize': _maxCacheSize,
        'cacheExpirationDays': _cacheExpiration.inDays,
      };
    } catch (e) {
      debugPrint('Failed to get cache stats: $e');
      return {};
    }
  }
}