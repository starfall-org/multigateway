import '../../features/home/domain/services/tts_service.dart';
import '../data/appearance.dart';
import '../data/language.dart';
import '../data/preferences.dart';
import '../../core/profile/data/ai_profile_store.dart';
import '../../features/home/domain/data/chat_store.dart';
import '../data/default_options.dart';
import '../../core/mcp/data/mcpserver_store.dart';
import '../../core/llm/data/provider_info_storage.dart';
import '../../core/speechservice/data/speechservice_store.dart';

/// Centralized service locator for application repositories and services.
/// Handles initialization and dependency management without external libraries.
class AppServices {
  // Singleton instance
  static final AppServices _instance = AppServices._internal();
  static AppServices get instance => _instance;

  AppServices._internal();

  // Repositories
  late final AppearanceSp appearanceSp;
  late final LanguageSp languageSp;
  late final PreferencesSp preferencesSp;
  late final ChatRepository chatRepository;
  late final AIProfileRepository aiProfileRepository;
  late final ProviderInfoStorage pInfStorage;
  late final DefaultOptionsRepository defaultOptionsRepository;
  late final MCPRepository mcpRepository;
  late final TTSRepository ttsRepository;
  late final TTSService ttsService;

  /// Initializes all repositories. Should be called before runApp.
  static Future<void> init() async {
    // Initialize repositories sequentially or in parallel as needed
    // Some might depend on Hive being initialized first (handled in main)

    // Core settings first
    _instance.appearanceSp = await AppearanceSp.init();
    _instance.languageSp = await LanguageSp.init();
    _instance.preferencesSp = await PreferencesSp.init();

    // Feature repositories
    _instance.pInfStorage = await ProviderInfoStorage.init();
    _instance.defaultOptionsRepository = await DefaultOptionsRepository.init();
    _instance.chatRepository = await ChatRepository.init();
    _instance.aiProfileRepository = await AIProfileRepository.init();
    _instance.mcpRepository = await MCPRepository.init();
    _instance.ttsRepository = await TTSRepository.init();

    // Services
    _instance.ttsService = TTSService();
  }
}
