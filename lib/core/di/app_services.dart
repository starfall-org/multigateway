import '../storage/ai_profile_repository.dart';
import '../storage/app_preferences_repository.dart';
import '../storage/appearances_repository.dart';
import '../storage/chat_repository.dart';
import '../storage/default_models_repository.dart';
import '../storage/language_repository.dart';
import '../storage/mcp_repository.dart';
import '../storage/provider_repository.dart';
import '../storage/tts_repository.dart';
import '../services/tts_service.dart';

/// Centralized service locator for application repositories and services.
/// Handles initialization and dependency management without external libraries.
class AppServices {
  // Singleton instance
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  AppServices._internal();

  // Repositories
  late final AppearancesRepository appearancesRepository;
  late final LanguageRepository languageRepository;
  late final AppPreferencesRepository appPreferencesRepository;
  late final ChatRepository chatRepository;
  late final AIProfileRepository aiProfileRepository;
  late final ProviderRepository providerRepository;
  late final DefaultModelsRepository defaultModelsRepository;
  late final MCPRepository mcpRepository;
  late final TTSRepository ttsRepository;
  late final TTSService ttsService;

  /// Initializes all repositories. Should be called before runApp.
  static Future<void> init() async {
    // Initialize repositories sequentially or in parallel as needed
    // Some might depend on Hive being initialized first (handled in main)
    
    // Core settings first
    _instance.appearancesRepository = await AppearancesRepository.init();
    _instance.languageRepository = await LanguageRepository.init();
    _instance.appPreferencesRepository = await AppPreferencesRepository.init();
    
    // Feature repositories
    _instance.providerRepository = await ProviderRepository.init();
    _instance.defaultModelsRepository = await DefaultModelsRepository.init();
    _instance.chatRepository = await ChatRepository.init();
    _instance.aiProfileRepository = await AIProfileRepository.init();
    _instance.mcpRepository = await MCPRepository.init();
    _instance.ttsRepository = await TTSRepository.init();
    
    // Services
    _instance.ttsService = TTSService();
  }
}