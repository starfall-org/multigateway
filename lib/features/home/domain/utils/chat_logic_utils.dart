import '../../../../core/llm/models/llm_provider/provider_info.dart';
import '../models/conversation.dart';

class ChatLogicUtils {
  /// Tạo tiêu đề cho cuộc trò chuyện dựa trên tin nhắn đầu tiên hoặc tệp đính kèm
  static String generateTitle(String text, List<String> attachments) {
    final base = text.isNotEmpty
        ? text
        : (attachments.isNotEmpty
              ? 'Attachments (${attachments.length})'
              : 'New Chat');
    return base.length > 30 ? '${base.substring(0, 30)}...' : base;
  }

  /// Định dạng nội dung tin nhắn kèm danh sách tệp đính kèm để gửi cho model
  static String formatAttachmentsForPrompt(
    String text,
    List<String> attachments,
  ) {
    if (attachments.isEmpty) return text;
    final names = attachments.map((p) => p.split('/').last).join(', ');
    return '${text.isEmpty ? '' : '$text\n'}[Attachments: $names]';
  }

  /// Xác định Provider và Model sẽ được sử dụng dựa trên cấu hình và trạng thái hiện tại
  static ({String provider, String model}) resolveProviderAndModel({
    required Conversation? currentSession,
    required bool persistSelection,
    required String? selectedProvider,
    required String? selectedModel,
    required List<Provider> providers,
  }) {
    if (persistSelection &&
        currentSession?.providerName != null &&
        currentSession?.modelName != null) {
      return (
        provider: currentSession!.providerName!,
        model: currentSession.modelName!,
      );
    }

    final providerName =
        selectedProvider ?? (providers.isNotEmpty ? providers.first.name : '');

    final modelName =
        selectedModel ??
        ((providers.isNotEmpty && providers.first.models.isNotEmpty)
            ? providers.first.models.first.name
            : '');

    return (provider: providerName, model: modelName);
  }
}
