import 'package:json_annotation/json_annotation.dart';

part 'translation_cache_entry.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TranslationCacheEntry {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  const TranslationCacheEntry({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  String get cacheKey =>
      '${sourceLanguage}_${targetLanguage}_${originalText.hashCode}';

  factory TranslationCacheEntry.fromJson(Map<String, dynamic> json) =>
      _$TranslationCacheEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationCacheEntryToJson(this);

  TranslationCacheEntry copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
  }) {
    return TranslationCacheEntry(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
