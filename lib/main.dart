import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/app/app.dart';
import 'package:multigateway/app/storage/appearance_storage.dart';
import 'package:multigateway/app/storage/translation_cache_storage.dart';
// Import TypeAdapters
import 'package:multigateway/core/chat/models/conversation_adapter.dart';
import 'package:multigateway/core/llm/models/llm_provider_info_adapter.dart';
import 'package:multigateway/core/mcp/models/mcp_adapter.dart';
import 'package:multigateway/core/profile/models/chat_profile_adapter.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with persistent directory and migration
  await _initHiveWithMigration();

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

/// Initialize Hive with migration from old support directory to new documents directory
Future<void> _initHiveWithMigration() async {
  // Get directories
  final docsDir = await getApplicationDocumentsDirectory();
  final supportDir = await getApplicationSupportDirectory();

  final newHivePath = '${docsDir.path}/hive';
  final oldHivePath = supportDir.path;

  // Check if we need to migrate from old path
  final oldHiveDir = Directory(oldHivePath);
  final newHiveDir = Directory(newHivePath);

  if (oldHiveDir.existsSync() && !newHiveDir.existsSync()) {
    try {
      // Create new directory
      await newHiveDir.create(recursive: true);

      // Copy all .hive files from old to new location
      await for (final entity in oldHiveDir.list()) {
        if (entity is File && entity.path.endsWith('.hive')) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final newFile = File('${newHiveDir.path}/$fileName');
          await entity.copy(newFile.path);
        }
      }

      // Clean up old directory after successful migration
      await oldHiveDir.delete(recursive: true).catchError((e) => oldHiveDir);
    } catch (e) {
      // If migration fails, continue with new path anyway
    }
  }

  // Initialize Hive with the new persistent path
  await Hive.initFlutter(newHivePath);

  // Register TypeAdapters for better performance
  _registerTypeAdapters();
}

/// Register all TypeAdapters for Hive storage optimization
void _registerTypeAdapters() {
  // Conversation adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ConversationAdapter());
  }

  // Chat profile adapters
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ThinkingLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(LlmChatConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ActiveMcpAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ModelToolAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(ChatProfileAdapter());
  }

  // LLM provider adapters
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(ProviderTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(AuthMethodAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(AuthorizationAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(ConfigurationAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(LlmProviderInfoAdapter());
  }

  // MCP adapters
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(McpProtocolAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(McpInfoAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(StdioConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(McpToolsListAdapter());
  }
}
