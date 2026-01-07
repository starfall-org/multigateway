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
  Future<String> getTargetLanguage() async {
    final storage = await PreferencesStorage.instance;
    final preferences = storage.currentPreferences.languageSetting;

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
  Future<String?> getTranslatedText(String text) async {
    final targetLanguage = await getTargetLanguage();
    if (targetLanguage == 'en') return text;

    final cacheKey = _getCacheKey(text, targetLanguage);
    return _translatedTexts[cacheKey];
  }

  /// Dịch text và cập nhật UI realtime
  /// Trả về text gốc ngay lập tức, sau đó notify khi có bản dịch
  String translate(String text) {
    // Khởi tạo translation trong background và trả về text gốc ngay
    _initializeTranslation(text);
    return text;
  }

  /// Khởi tạo quá trình dịch trong background
  Future<void> _initializeTranslation(String text) async {
    try {
      final targetLanguage = await getTargetLanguage();

      // Nếu target là English (giống source), không cần dịch
      if (targetLanguage == 'en') {
        return;
      }

      final cacheKey = _getCacheKey(text, targetLanguage);

      // Kiểm tra in-memory cache trước (cho realtime update)
      if (_translatedTexts.containsKey(cacheKey)) {
        // Đã có bản dịch, notify để UI update
        notifyListeners();
        return;
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
        notifyListeners();
        return;
      }

      // Nếu đang có request pending cho text này, không gọi API lại
      if (_pendingRequests.containsKey(cacheKey)) {
        return;
      }

      // Tạo completer để track request
      final completer = Completer<String>();
      _pendingRequests[cacheKey] = completer;

      // Gọi API dịch trong background
      _translateInBackground(text, targetLanguage, cacheKey, completer);
    } catch (e) {
      debugPrint('Translation initialization failed: $e');
    }
  }

  /// Lấy text đã dịch hoặc text gốc
  String getTranslatedOrOriginal(String text) {
    // Sử dụng synchronous getter để UI có thể render ngay
    try {
      // Lấy target language từ cached value nếu có thể
      final targetLanguage = _getCachedTargetLanguage();
      if (targetLanguage == null || targetLanguage == 'en') return text;

      final cacheKey = _getCacheKey(text, targetLanguage);
      return _translatedTexts[cacheKey] ?? text;
    } catch (e) {
      return text;
    }
  }

  String? _cachedTargetLanguage;
  DateTime? _lastLanguageUpdate;

  /// Lấy cached target language (update mỗi 5 giây)
  String? _getCachedTargetLanguage() {
    final now = DateTime.now();
    if (_cachedTargetLanguage == null ||
        _lastLanguageUpdate == null ||
        now.difference(_lastLanguageUpdate!) > const Duration(seconds: 5)) {
      // Update cache trong background
      getTargetLanguage().then((lang) {
        _cachedTargetLanguage = lang;
        _lastLanguageUpdate = now;
      });
    }
    return _cachedTargetLanguage;
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
  final manager = TranslationManager.instance;
  // Khởi tạo translation process
  manager.translate(text);
  // Trả về text đã dịch hoặc text gốc
  return manager.getTranslatedOrOriginal(text);
}
