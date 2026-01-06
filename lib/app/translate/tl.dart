import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:multigateway/app/storage/preferences_storage.dart';
import 'package:multigateway/app/storage/translation_cache_storage.dart';
import 'package:translator/translator.dart';

/// TranslationManager quản lý việc dịch và notify UI khi có bản dịch mới
class TranslationManager extends ChangeNotifier {
  static TranslationManager? _instance;
  static TranslationManager get instance {
    _instance ??= TranslationManager._internal();
    return _instance!;
  }

  TranslationManager._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  /// Map lưu các request đang pending để tránh gọi API đồng thời cho cùng một text
  final Map<String, Completer<String>> _pendingRequests = {};

  /// Map lưu các bản dịch đã hoàn thành (in-memory cache cho realtime update)
  final Map<String, String> _translatedTexts = {};

  /// Tạo cache key từ text và target language
  String _getCacheKey(String text, String targetLanguage) {
    return '${targetLanguage}_$text';
  }

  /// Lấy target language từ preferences
  String getTargetLanguage() {
    final preferences =
        PreferencesStorage.instance.currentPreferences.languageSetting;

    if (preferences.autoDetect || preferences.languageCode == 'auto') {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      if (locale.languageCode.toLowerCase() == 'zh') {
        final country = (locale.countryCode ?? '').toUpperCase();
        return country == 'TW' ? 'zh-TW' : 'zh-CN';
      }
      return locale.languageCode.toLowerCase();
    }
    return preferences.languageCode.toLowerCase();
  }

  /// Lấy bản dịch đã cache (nếu có)
  String? getTranslatedText(String text) {
    final targetLanguage = getTargetLanguage();
    if (targetLanguage == 'en') return text;

    final cacheKey = _getCacheKey(text, targetLanguage);
    return _translatedTexts[cacheKey];
  }

  /// Dịch text và cập nhật UI realtime
  /// Trả về text gốc ngay lập tức, sau đó notify khi có bản dịch
  String translate(String text) {
    try {
      final targetLanguage = getTargetLanguage();

      // Nếu target là English (giống source), return text gốc
      if (targetLanguage == 'en') {
        return text;
      }

      final cacheKey = _getCacheKey(text, targetLanguage);

      // Kiểm tra in-memory cache trước (cho realtime update)
      if (_translatedTexts.containsKey(cacheKey)) {
        return _translatedTexts[cacheKey]!;
      }

      // Kiểm tra persistent cache
      final translationCacheRepo = TranslationCacheStorage.instance;
      final cached = translationCacheRepo.getCachedTranslation(
        originalText: text,
        sourceLanguage: 'en',
        targetLanguage: targetLanguage,
      );

      if (cached != null) {
        _translatedTexts[cacheKey] = cached.translatedText;
        return cached.translatedText;
      }

      // Nếu đang có request pending cho text này, không gọi API lại
      if (_pendingRequests.containsKey(cacheKey)) {
        return text;
      }

      // Tạo completer để track request
      final completer = Completer<String>();
      _pendingRequests[cacheKey] = completer;

      // Gọi API dịch trong background
      _translateInBackground(text, targetLanguage, cacheKey, completer);

      // Trả về text gốc ngay lập tức
      return text;
    } catch (e) {
      debugPrint('Translation failed: $e');
      return text;
    }
  }

  /// Dịch text trong background và notify UI khi hoàn thành
  Future<void> _translateInBackground(
    String text,
    String targetLanguage,
    String cacheKey,
    Completer<String> completer,
  ) async {
    try {
      final result = await _translator.translate(
        text,
        from: 'en',
        to: targetLanguage,
      );

      // Lưu vào in-memory cache
      _translatedTexts[cacheKey] = result.text;

      // Lưu vào persistent cache
      final translationCacheRepo = TranslationCacheStorage.instance;
      await translationCacheRepo.saveTranslation(
        originalText: text,
        sourceLanguage: 'en',
        targetLanguage: targetLanguage,
        translatedText: result.text,
      );

      // Complete request
      completer.complete(result.text);

      // Notify UI để rebuild với bản dịch mới
      notifyListeners();
    } catch (e) {
      debugPrint('Background translation failed: $e');
      completer.completeError(e);
    } finally {
      // Xóa pending request
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Xóa cache và reset state
  void clearCache() {
    _translatedTexts.clear();
    _pendingRequests.clear();
    notifyListeners();
  }

  /// Kiểm tra xem có đang dịch text nào không
  bool get isTranslating => _pendingRequests.isNotEmpty;

  /// Số lượng bản dịch đã cache trong memory
  int get cachedCount => _translatedTexts.length;
}


/// Hàm tiện ích để dịch text
/// Sử dụng: tl('Hello') -> 'Xin chào' (nếu target language là Vietnamese)
String tl(String text) {
  return TranslationManager.instance.translate(text);
}
