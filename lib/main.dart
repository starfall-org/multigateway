import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/app/app.dart';
import 'package:multigateway/app/storage/appearance_storage.dart';
import 'package:multigateway/app/storage/translation_cache_storage.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (lazy initialization for storage will use this)
  final supportDir = await getApplicationSupportDirectory();
  await Hive.initFlutter(supportDir.path);

  // Load settings
  final appearanceStorage = await AppearanceStorage.instance;

  // Initialize translation cache storage
  await TranslationCacheStorage.init();

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
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(MultiGatewayApp(appearanceStorage: appearanceStorage));
}
