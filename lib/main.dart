import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/services/custom_asset_loader.dart';
import 'core/di/app_services.dart';
import 'core/utils.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  // Initialize all app services and repositories
  await AppServices.init();

  // Initialize icons (non-blocking)
  initIcons();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );

  // Thiết lập edge-to-edge ban đầu, style cụ thể sẽ được cập nhật trong AppTheme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final selectedLocale = AppServices.instance.languageRepository
      .getInitialLocale(deviceLocale);

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
