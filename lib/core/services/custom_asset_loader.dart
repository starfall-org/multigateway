import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class CustomAssetLoader extends AssetLoader {
  const CustomAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    try {
      // Validate locale
      if (locale.languageCode.isEmpty) {
        locale = const Locale('en');
      }
      
      // Xác định tên file dựa trên locale
      String fileName;
      if (locale.languageCode == 'zh') {
        // Đối với tiếng Trung, sử dụng mã vùng để phân biệt giản thể/phồn thể
        if (locale.countryCode != null &&
            (locale.countryCode == 'CN' || locale.countryCode == 'TW')) {
          fileName = '${locale.languageCode}_${locale.countryCode}.json';
        } else {
          fileName = '${locale.languageCode}_CN.json'; // Default to simplified Chinese
        }
      } else {
        // Đối với các ngôn ngữ khác, chỉ sử dụng mã ngôn ngữ
        fileName = '${locale.languageCode}.json';
      }

      final String jsonString = await rootBundle.loadString('$path/$fileName');
      final Map<String, dynamic> result = jsonDecode(jsonString);
      
      // Validate that the JSON is not empty and has valid structure
      if (result.isEmpty) {
        throw Exception('Empty translation file');
      }
      
      return result;
    } catch (e) {
      print('Error loading translation for ${locale.languageCode}: $e');
      
      // Nếu không tìm thấy file, fallback sang tiếng Anh
      if (locale.languageCode != 'en') {
        try {
          final String jsonString = await rootBundle.loadString('$path/en.json');
          return jsonDecode(jsonString);
        } catch (fallbackError) {
          print('Error loading fallback English translation: $fallbackError');
          // Return a minimal valid structure to prevent complete failure
          return {
            'app_title': 'LMHub',
            'error': 'Translation loading failed'
          };
        }
      }
      
      // If even English fails, return minimal structure
      return {
        'app_title': 'LMHub',
        'error': 'Translation loading failed'
      };
    }
  }
}