import '../core/storage/ai_profile_repository.dart';
import '../core/storage/app_preferences_repository.dart';
import '../core/storage/AppearanceSetting_repository.dart';
import '../core/storage/chat_repository.dart';
import '../core/storage/default_models_repository.dart';
import '../core/storage/language_repository.dart';
import '../core/storage/mcp_repository.dart';
import '../core/storage/provider_repository.dart';
import '../core/storage/tts_repository.dart';
import '../features/chat/services/tts_service.dart';

/// Centralized service locator for application repositories and services.
/// Handles initialization and dependency management without external libraries.
class AppServices {
  // Singleton instance
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  AppServices._internal();

  // Repositories
  late final AppearanceSettingRepository AppearanceSettingRepository;
  late final LanguageSp LanguageSp;
  late final PreferencesSp PreferencesSp;
  late final ChatRepository chatRepository;
  late final AIProfileRepository aiProfileRepository;
  late final ProviderRepository providerRepository;
  late final DefaultOptionsRepository DefaultOptionsRepository;
  late final MCPRepository mcpRepository;
  late final TTSRepository ttsRepository;
  late final TTSService ttsService;

  /// Initializes all repositories. Should be called before runApp.
  static Future<void> init() async {
    // Initialize repositories sequentially or in parallel as needed
    // Some might depend on Hive being initialized first (handled in main)

    // Core settings first
    _instance.AppearanceSettingRepository = await AppearanceSettingRepository.init();
    _instance.LanguageSp = await LanguageSp.init();
    _instance.PreferencesSp = await PreferencesSp.init();

    // Feature repositories
    _instance.providerRepository = await ProviderRepository.init();
    _instance.DefaultOptionsRepository = await DefaultOptionsRepository.init();
    _instance.chatRepository = await ChatRepository.init();
    _instance.aiProfileRepository = await AIProfileRepository.init();
    _instance.mcpRepository = await MCPRepository.init();
    _instance.ttsRepository = await TTSRepository.init();

    // Services
    _instance.ttsService = TTSService();
  }
}
