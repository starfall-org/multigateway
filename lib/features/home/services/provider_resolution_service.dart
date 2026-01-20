import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/utils/chat_logic_utils.dart';
import 'package:uuid/uuid.dart';

/// Service xử lý logic lựa chọn và phân giải provider/model
class ProviderResolutionService {
  /// Tạo profile mặc định khi không có profile được chọn
  static ChatProfile createDefaultProfile() {
    return ChatProfile(
      id: const Uuid().v4(),
      name: 'Default Profile',
      config: LlmChatConfig(systemPrompt: '', enableStream: true),
    );
  }

  /// Phân giải provider và model từ các thông tin hiện có
  static Future<({String providerName, String modelName})> resolveProviderAndModel({
    required String? selectedProviderName,
    required String? selectedModelName,
    required Conversation? currentSession,
    bool persistSelection = false,
  }) async {
    final providerRepo = await LlmProviderInfoStorage.init();
    final providersList = await providerRepo.getItemsAsync();

    if (persistSelection &&
        currentSession != null &&
        currentSession.providerId.isNotEmpty &&
        currentSession.modelId.isNotEmpty) {
      return (
        providerName: currentSession.providerId,
        modelName: currentSession.modelId,
      );
    }

    final resolved = ChatLogicUtils.resolveProviderAndModel(
      currentSession: currentSession,
      persistSelection: persistSelection,
      selectedProvider: selectedProviderName,
      selectedModel: selectedModelName,
      providers: providersList,
      providerModels: {}, // Sẽ được điền từ controller nếu cần
    );

    return (
      providerName: resolved.provider,
      modelName: resolved.model,
    );
  }

  /// Validate provider và model có tồn tại không
  static Future<bool> validateProviderAndModel(
    String providerName,
    String modelName,
  ) async {
    if (providerName.isEmpty || modelName.isEmpty) return false;
    
    final providerRepo = await LlmProviderInfoStorage.init();
    final providers = await providerRepo.getItemsAsync();
    
    return providers.any((p) => p.name == providerName);
  }

  /// Lấy danh sách provider available
  static Future<List<LlmProviderInfo>> getAvailableProviders() async {
    final providerRepo = await LlmProviderInfoStorage.init();
    return await providerRepo.getItemsAsync();
  }
}
