import 'package:multigateway/core/llm/models/legacy_llm_model.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/chat/models/conversation.dart';

class ChatLogicUtils {
  /// Tạo tiêu đề cho cuộc trò chuyện dựa trên tin nhắn đầu tiên hoặc tệp đính kèm
  static String generateTitle(String text, List<String> files) {
    final base = text.isNotEmpty
        ? text
        : (files.isNotEmpty ? 'Attachments (${files.length})' : 'New Chat');
    return base.length > 30 ? '${base.substring(0, 30)}...' : base;
  }

  /// Định dạng nội dung tin nhắn kèm danh sách tệp đính kèm để gửi cho model
  static String formatFilesForPrompt(String text, List<String> files) {
    if (files.isEmpty) return text;
    final names = files.map((p) => p.split('/').last).join(', ');
    return '${text.isEmpty ? '' : '$text\n'}[Files: $names]';
  }

  /// Xác định Provider và Model sẽ được sử dụng dựa trên cấu hình và trạng thái hiện tại
  static ({String provider, String model}) resolveProviderAndModel({
    required Conversation? currentSession,
    required bool persistSelection,
    required String? selectedProvider,
    required String? selectedModel,
    required List<LlmProviderInfo> providers,
    required Map<String, List<AIModel>> providerModels,
  }) {
    if (persistSelection &&
        currentSession?.providerId != null &&
        currentSession?.modelName != null) {
      return (
        provider: currentSession!.providerId,
        model: currentSession.modelName,
      );
    }

    final provider = providers.isNotEmpty ? providers.first : null;
    final providerName = selectedProvider ?? (provider?.name ?? '');

    final firstProviderModels = provider != null
        ? providerModels[provider.id] ?? []
        : [];
    final modelName =
        selectedModel ??
        (firstProviderModels.isNotEmpty ? firstProviderModels.first.name : '');

    return (provider: providerName, model: modelName);
  }
}
