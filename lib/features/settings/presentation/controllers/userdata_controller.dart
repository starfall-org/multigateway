import 'package:multigateway/app/storage/translation_cache_storage.dart';
import 'package:multigateway/core/chat/storage/conversation_storage.dart';
import 'package:multigateway/core/llm/storage/llm_provider_info_storage.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:signals/signals.dart';

/// Controller tập trung số liệu và thao tác dữ liệu người dùng
class UserDataController {
  final conversationCount = signal<int>(0);
  final profileCount = signal<int>(0);
  final providerCount = signal<int>(0);
  final isProcessing = signal<bool>(false);

  Future<void> initialize() async {
    await refreshStats();
  }

  Future<void> refreshStats() async {
    final conversationStorage = await ConversationStorage.instance;
    final profileStorage = await ChatProfileStorage.instance;
    final providerStorage = await LlmProviderInfoStorage.instance;

    conversationCount.value = conversationStorage.getItems().length;
    profileCount.value = profileStorage.getItems().length;
    providerCount.value = providerStorage.getItems().length;
  }

  Future<void> backupData() => _runAction(() async {
        // Placeholder: real backup would persist to file/cloud
        await Future.delayed(const Duration(milliseconds: 400));
      });

  Future<void> restoreData() => _runAction(() async {
        await Future.delayed(const Duration(milliseconds: 400));
      });

  Future<void> exportData() => _runAction(() async {
        await Future.delayed(const Duration(milliseconds: 400));
      });

  Future<void> anonymizeData() => _runAction(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });

  Future<void> deleteAllData() => _runAction(() async {
        final conversationStorage = await ConversationStorage.instance;
        await conversationStorage.clear();

        // Clear translation cache as part of data cleanup
        final translationCache = await TranslationCacheStorage.init();
        await translationCache.clearCache();

        await refreshStats();
      });

  /// Xóa toàn bộ lịch sử trò chuyện
  Future<void> deleteConversationHistory() => _runAction(() async {
        final conversationStorage = await ConversationStorage.instance;
        await conversationStorage.clear();
        await refreshStats();
      });

  Future<void> cleanCache() => _runAction(() async {
        final translationCache = await TranslationCacheStorage.init();
        await translationCache.clearCache();
      });

  Future<void> manageFiles() => _runAction(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });

  Future<void> _runAction(Future<void> Function() action) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      await action();
    } finally {
      isProcessing.value = false;
    }
  }

  void dispose() {
    conversationCount.dispose();
    profileCount.dispose();
    providerCount.dispose();
    isProcessing.dispose();
  }
}
