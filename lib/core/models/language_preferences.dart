import 'dart:ui';

class LanguagePreferences {
  final String languageCode;
  final String? countryCode;
  final bool autoDetectLanguage;

  const LanguagePreferences({
    required this.languageCode,
    this.countryCode,
    this.autoDetectLanguage = true,
  });

  factory LanguagePreferences.defaults() {
    return const LanguagePreferences(
      languageCode: 'auto',
      autoDetectLanguage: true,
    );
  }

  factory LanguagePreferences.fromJson(Map<String, dynamic> json) {
    return LanguagePreferences(
      languageCode: json['languageCode'] ?? 'auto',
      countryCode: json['countryCode'],
      autoDetectLanguage: json['autoDetectLanguage'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'autoDetectLanguage': autoDetectLanguage,
    };
  }

  String toJsonString() {
    return toString();
  }

  factory LanguagePreferences.fromJsonString(String json) {
    try {
      // Use proper JSON parsing for reliability
      if (json.trim().isEmpty) {
        return LanguagePreferences.defaults();
      }
      
      // Handle both proper JSON and the old string format
      if (json.trim().startsWith('{')) {
        // Try to parse as proper JSON first
        final Map<String, dynamic> data = _parseJsonSafely(json);
        return LanguagePreferences.fromJson(data);
      } else {
        // Fallback to the old string format parsing
        return _parseLegacyFormat(json);
      }
    } catch (e) {
      // If all parsing fails, return defaults
      return LanguagePreferences.defaults();
    }
  }

  static Map<String, dynamic> _parseJsonSafely(String json) {
    try {
      // Simple JSON parser for our specific format
      final Map<String, dynamic> data = {};
      final cleanJson = json.trim();
      
      // Extract values using regex for more reliable parsing
      final languageCodeMatch = RegExp(r'"languageCode":"([^"]*)"').firstMatch(cleanJson);
      final countryCodeMatch = RegExp(r'"countryCode":"([^"]*)"').firstMatch(cleanJson);
      final autoDetectMatch = RegExp(r'"autoDetectLanguage":(true|false)').firstMatch(cleanJson);
      
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

  static LanguagePreferences _parseLegacyFormat(String json) {
    // Fallback to the old string format parsing
    final parts = json.split(',');
    final Map<String, dynamic> data = {};
    
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().replaceAll('{', '').replaceAll('"', '');
        final value = keyValue[1].trim().replaceAll('}', '').replaceAll('"', '');
        data[key] = value;
      }
    }
    
    return LanguagePreferences.fromJson(data);
  }

  Locale? getLocale() {
    if (autoDetectLanguage || languageCode == 'auto') {
      return null; // Use auto-detection
    }
    
    if (countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    return Locale(languageCode);
  }

  LanguagePreferences copyWith({
    String? languageCode,
    String? countryCode,
    bool? autoDetectLanguage,
  }) {
    return LanguagePreferences(
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
    return other is LanguagePreferences &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.autoDetectLanguage == autoDetectLanguage;
  }

  @override
  int get hashCode {
    return languageCode.hashCode ^ countryCode.hashCode ^ autoDetectLanguage.hashCode;
  }
}