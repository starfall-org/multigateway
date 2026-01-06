import '../../features/home/domain/domain.dart';
import 'package:llm/llm.dart';
import 'package:mcp/mcp.dart';
import '../../core/profile/profile.dart';
import '../../core/speech/speech.dart';

import '../../core/llm/data/provider_info_storage.dart';
import '../../core/storage/mcpserver_store.dart';

import '../storage/appearance.dart';
import '../storage/preferences.dart';
import '../storage/default_options.dart';

/// Centralized service locator for application repositories and services.
/// Handles initialization and dependency management without external libraries.
class AppServices {
  // Singleton instance
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  AppServices._internal();

  // Repositories
  late final AppearanceStorage appearanceSp;
  late final PreferencesStorage preferencesSp;
  late final ChatRepository chatRepository;
  late final AIProfileRepository aiProfileRepository;
  late final LlmProviderInfoStorage pInfStorage;
  late final DefaultOptionsStorage defaultOptionsRepository;
  late final MCPRepository mcpRepository;
  late final TTSRepository ttsRepository;
  late final TTSService ttsService;

  /// Initializes all repositories. Should be called before runApp.
  static Future<void> init() async {
    // Initialize repositories sequentially or in parallel as needed
    // Some might depend on Hive being initialized first (handled in main)

    // Core settings first
    _instance.appearanceSp = await AppearanceStorage.init();
    _instance.preferencesSp = await PreferencesStorage.init();

    // Feature repositories
    _instance.pInfStorage = await LlmProviderInfoStorage.init();
    _instance.defaultOptionsRepository = await DefaultOptionsStorage.init();
    _instance.chatRepository = await ChatRepository.init();
    _instance.aiProfileRepository = await AIProfileRepository.init();
    _instance.mcpRepository = await MCPRepository.init();
    _instance.ttsRepository = await TTSRepository.init();

    // Services
    _instance.ttsService = TTSService();
  }
}
