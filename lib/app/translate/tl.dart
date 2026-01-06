import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:translator/translator.dart';

import '../storage/translation_cache.dart';
import '../storage/preferences.dart';
// import 'service.dart';

/// Dịch text từ English sang ngôn ngữ được cài đặt trong language preferences
/// Input is always English
/// Output is the language have set in language preference
/// if no translate model is set or error or the default language is set to English, return the text as it is
String tl(String text) {
  final translator = GoogleTranslator();
  try {
    // Lấy language preferences hiện tại
    final preferences = PreferencesStorage.instance.currentPreferences.languageSetting;

    // Xác định target language
    String targetLanguage;
    if (preferences.autoDetect || preferences.languageCode == 'auto') {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      if (locale.languageCode.toLowerCase() == 'zh') {
        final country = (locale.countryCode ?? '').toUpperCase();
        targetLanguage = country == 'TW' ? 'zh-TW' : 'zh-CN';
      } else {
        targetLanguage = locale.languageCode.toLowerCase();
      }
    } else {
      targetLanguage = preferences.languageCode.toLowerCase();
    }

    // Nếu target là English (giống source), return text gốc
    if (targetLanguage == 'en') {
      return text;
    }

    // Kiểm tra cached translation trước
    try {
      final translationCacheRepo = TranslationCacheStorage.instance;
      final cached = translationCacheRepo.getCachedTranslation(
        originalText: text,
        sourceLanguage: 'en',
        targetLanguage: targetLanguage,
      );
      if (cached != null) {
        return cached.translatedText;
      }
    } catch (e) {
      debugPrint('Translation cache not available: $e');
    }

    // Giữ logic async nhưng bọc trong hàm sync: chạy nền để dịch và populate cache
    scheduleMicrotask(() async {
      try {
        var result = await translator.translate(
          text,
          from: 'en',
          to: targetLanguage,
        );
        final translationCacheRepo = TranslationCacheStorage.instance;
        translationCacheRepo.saveTranslation(
          originalText: text,
          sourceLanguage: 'en',
          targetLanguage: targetLanguage,
          translatedText: result.text,
        );
      } catch (e) {
        debugPrint('Background translation failed: $e');
      }
    });

    // Trả về text gốc ngay lập tức
    return text;
  } catch (e) {
    debugPrint('Translation failed: $e');
    return text;
  }
}
