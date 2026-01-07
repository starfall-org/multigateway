import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/app/app.dart';
import 'package:multigateway/firebase_options.dart'; 
import 'package:multigateway/shared/utils/icon_builder.dart';

import 'package:multigateway/app/storage/appearance_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive (lazy initialization for storage will use this)
  await Hive.initFlutter();

  // Load settings
  final appearanceStorage = await AppearanceStorage.instance;

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
