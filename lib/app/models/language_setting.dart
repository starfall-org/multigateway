import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'language_setting.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LanguageSetting {
  final String languageCode;
  final String? countryCode;
  final bool autoDetectLanguage;

  const LanguageSetting({
    required this.languageCode,
    this.countryCode,
    this.autoDetectLanguage = true,
  });

  factory LanguageSetting.defaults() {
    return const LanguageSetting(
      languageCode: 'auto',
      autoDetectLanguage: true,
    );
  }

  factory LanguageSetting.fromJson(Map<String, dynamic> json) =>
      _$LanguageSettingFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageSettingToJson(this);

  String toJsonString() {
    return toString();
  }

  factory LanguageSetting.fromJsonString(String json) {
    try {
      if (json.trim().isEmpty) {
        return LanguageSetting.defaults();
      }

      if (json.trim().startsWith('{')) {
        final Map<String, dynamic> data = _parseJsonSafely(json);
        return LanguageSetting.fromJson(data);
      } else {
        return _parseLegacyFormat(json);
      }
    } catch (e) {
      return LanguageSetting.defaults();
    }
  }

  static Map<String, dynamic> _parseJsonSafely(String json) {
    try {
      final Map<String, dynamic> data = {};
      final cleanJson = json.trim();

      final languageCodeMatch = RegExp(
        r'"languageCode":"([^"]*)"',
      ).firstMatch(cleanJson);
      final countryCodeMatch = RegExp(
        r'"countryCode":"([^"]*)"',
      ).firstMatch(cleanJson);
      final autoDetectMatch = RegExp(
        r'"autoDetectLanguage":(true|false)',
      ).firstMatch(cleanJson);

      if (languageCodeMatch != null) {
        data['languageCode'] = languageCodeMatch.group(1);
      }
      if (countryCodeMatch != null) {
        data['countryCode'] = countryCodeMatch.group(1);
      }
      if (autoDetectMatch != null) {
        data['autoDetectLanguage'] = autoDetectMatch.group(1) == 'true';
      }

      return data;
    } catch (e) {
      return {};
    }
  }

  static LanguageSetting _parseLegacyFormat(String json) {
    final parts = json.split(',');
    final Map<String, dynamic> data = {};

    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().replaceAll('{', '').replaceAll('"', '');
        final value = keyValue[1]
            .trim()
            .replaceAll('}', '')
            .replaceAll('"', '');
        data[key] = value;
      }
    }

    return LanguageSetting.fromJson(data);
  }

  Locale? getLocale() {
    if (autoDetectLanguage || languageCode == 'auto') {
      return null;
    }

    if (countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    return Locale(languageCode);
  }

  LanguageSetting copyWith({
    String? languageCode,
    String? countryCode,
    bool? autoDetectLanguage,
  }) {
    return LanguageSetting(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
    );
  }

  @override
  String toString() {
    return '{"languageCode":"$languageCode","countryCode":"$countryCode","autoDetectLanguage":$autoDetectLanguage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageSetting &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.autoDetectLanguage == autoDetectLanguage;
  }

  @override
  int get hashCode {
    return languageCode.hashCode ^
        countryCode.hashCode ^
        autoDetectLanguage.hashCode;
  }
}
