import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../core/llm/provider/base.dart';
import '../data/translation_cache.dart';

class TranslationService {
  static TranslationService? _instance;

  static TranslationService get instance {
    if (_instance == null) {
      throw Exception('TranslationService not initialized. Call init() first.');
    }
    return _instance!;
  }

  late final AIBaseApi _aiApi;
  late final TranslationCacheRepository _cacheRepository;
  late final String _defaultModel;

  /// Khởi tạo TranslationService
  static Future<TranslationService> init({
    required AIBaseApi aiApi,
    required TranslationCacheRepository cacheRepository,
    String defaultModel = 'gpt-3.5-turbo',
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    _instance = TranslationService._internal();
    _instance!._aiApi = aiApi;
    _instance!._cacheRepository = cacheRepository;
    _instance!._defaultModel = defaultModel;

    return _instance!;
  }

  TranslationService._internal();

  /// Dịch text từ source language sang target language
  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? model,
  }) async {
    // Nếu source và target language giống nhau, return text gốc
    if (sourceLanguage.toLowerCase() == targetLanguage.toLowerCase()) {
      return text;
    }

    // Kiểm tra cache trước
    final cached = _cacheRepository.getCachedTranslation(
      originalText: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    if (cached != null) {
      return cached.translatedText;
    }

    try {
      // Sử dụng AI để dịch
      final translatedText = await _performAITranslation(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        model: model ?? _defaultModel,
      );

      // Lưu vào cache
      await _cacheRepository.saveTranslation(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      return translatedText;
    } catch (e) {
      // Nếu có lỗi, return text gốc
      debugPrint('Translation failed: $e');
      return text;
    }
  }

  /// Thực hiện dịch thuật bằng AI
  Future<String> _performAITranslation({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    required String model,
  }) async {
    final prompt = _buildTranslationPrompt(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    final request = AIRequest(
      model: model,
      messages: [
        AIMessage(
          role: 'user',
          content: [AIContent(type: AIContentType.text, text: prompt)],
        ),
      ],
      temperature: 0.1, // Low temperature for consistent translations
      maxTokens: 1000,
    );

    final response = await _aiApi.generate(request);

    if (response.text.trim().isEmpty) {
      throw Exception('Empty translation response');
    }

    return response.text.trim();
  }

  /// Xây dựng prompt cho AI translation
  String _buildTranslationPrompt({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    final sourceLangName = _getLanguageName(sourceLanguage);
    final targetLangName = _getLanguageName(targetLanguage);

    return '''Please translate the following text from $sourceLangName to $targetLangName. 

Rules:
1. Provide only the translation, no explanations or additional text
2. Maintain the original meaning and tone
3. Keep formatting and structure if present
4. If the text contains technical terms, translate them appropriately

Text to translate:
"$text"

Translation:''';
  }

  /// Lấy tên đầy đủ của ngôn ngữ từ language code
  String _getLanguageName(String languageCode) {
    final languageNames = {
      'en': 'English',
      'vi': 'Vietnamese',
      'zh-CN': 'Chinese (Simplified)',
      'zh-TW': 'Chinese (Traditional)',
      'ja': 'Japanese',
      'fr': 'French',
      'de': 'German',
      'es': 'Spanish',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'th': 'Thai',
      'id': 'Indonesian',
      'ms': 'Malay',
      'tl': 'Filipino',
      'auto': 'auto-detected language',
    };

    return languageNames[languageCode.toLowerCase()] ??
        languageCode.toUpperCase();
  }

  /// Batch translate multiple texts
  Future<List<String>> translateBatch({
    required List<String> texts,
    required String sourceLanguage,
    required String targetLanguage,
    String? model,
  }) async {
    final results = <String>[];

    for (final text in texts) {
      final translated = await translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        model: model,
      );
      results.add(translated);
    }

    return results;
  }

  /// Lấy thống kê cache
  Map<String, dynamic> getCacheStats() {
    return _cacheRepository.getCacheStats();
  }

  /// Xóa cache
  Future<void> clearCache() async {
    await _cacheRepository.clearCache();
  }

  /// Kiểm tra xem có thể dịch từ source sang target không
  bool canTranslate(String sourceLanguage, String targetLanguage) {
    // Hiện tại hỗ trợ tất cả ngôn ngữ, có thể mở rộng sau
    return sourceLanguage.toLowerCase() != targetLanguage.toLowerCase();
  }

  /// Lấy danh sách ngôn ngữ được hỗ trợ
  List<String> getSupportedLanguages() {
    return [
      'en',
      'vi',
      'zh',
      'ja',
      'fr',
      'de',
      'es',
      'it',
      'pt',
      'ru',
      'ko',
      'ar',
      'hi',
      'th',
      'id',
      'ms',
      'tl',
    ];
  }
}
