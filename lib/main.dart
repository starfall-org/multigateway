import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/models/language_preferences.dart';
import 'core/storage/theme_repository.dart';
import 'core/storage/language_repository.dart';
import 'core/services/custom_asset_loader.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize ThemeRepository
  await ThemeRepository.init();

  // Initialize LanguageRepository
  await LanguageRepository.init();

  // On Android, prevent content from drawing under status/navigation bars
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  // Lấy preferences ngôn ngữ đã lưu với error handling
  Locale selectedLocale;
  try {
    final languageRepo = LanguageRepository.instance;
    final preferences = languageRepo.currentPreferences;

    if (preferences.autoDetectLanguage || preferences.languageCode == 'auto') {
      // Tự động phát hiện ngôn ngữ thiết bị
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      selectedLocale = _getSupportedLocale(deviceLocale);
    } else {
      // Sử dụng ngôn ngữ đã lưu với error handling
      selectedLocale = _getLocaleFromPreferences(preferences);
    }
  } catch (e) {
    // Nếu có lỗi khi đọc preferences, fallback sang tiếng Anh
    debugPrint('Error loading language preferences: $e');
    selectedLocale = const Locale('en');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('fr'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: false,
      assetLoader: CustomAssetLoader(),
      startLocale: selectedLocale,
      child: const AIGatewayApp(),
    ),
  );
}

Locale _getSupportedLocale(Locale deviceLocale) {
  try {
    // Validate device locale
    if (deviceLocale.languageCode.isEmpty) {
      return const Locale('en');
    }

    // Danh sách các locale được hỗ trợ
    const supportedLocales = [
      Locale('en'),
      Locale('vi'),
      Locale('zh', 'CN'),
      Locale('zh', 'TW'),
      Locale('ja'),
      Locale('fr'),
      Locale('de'),
    ];

    // Kiểm tra xem locale của thiết bị có được hỗ trợ trực tiếp không
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode &&
          supportedLocale.countryCode == deviceLocale.countryCode) {
        return supportedLocale;
      }
    }

    // Kiểm tra xem ngôn ngữ có được hỗ trợ không (không quan tâm đến quốc gia)
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode) {
        // Đối với tiếng Trung, ưu tiên giản thể nếu không có quốc gia cụ thể
        if (deviceLocale.languageCode == 'zh') {
          return const Locale('zh', 'CN');
        }
        return supportedLocale;
      }
    }

    // Fallback sang tiếng Anh
    return const Locale('en');
  } catch (e) {
    debugPrint('Error getting supported locale: $e');
    return const Locale('en');
  }
}

// Hàm để lấy locale từ preferences với error handling
Locale _getLocaleFromPreferences(LanguagePreferences preferences) {
  try {
    // Validate language code
    if (preferences.languageCode.isEmpty) {
      return const Locale('en');
    }

    // Check if the language is supported
    final supportedLanguages = ['en', 'vi', 'zh', 'ja', 'fr', 'de'];
    if (!supportedLanguages.contains(preferences.languageCode)) {
      return const Locale('en');
    }

    // For Chinese, we need country code
    if (preferences.languageCode == 'zh') {
      if (preferences.countryCode != null &&
          (preferences.countryCode == 'CN' ||
              preferences.countryCode == 'TW')) {
        return Locale(preferences.languageCode, preferences.countryCode);
      } else {
        return const Locale('zh', 'CN'); // Default to simplified Chinese
      }
    }

    // For other languages, country code is optional
    if (preferences.countryCode != null &&
        preferences.countryCode!.isNotEmpty) {
      return Locale(preferences.languageCode, preferences.countryCode);
    }

    return Locale(preferences.languageCode);
  } catch (e) {
    debugPrint('Error parsing locale from preferences: $e');
    return const Locale('en');
  }
}
