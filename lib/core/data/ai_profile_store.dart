import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/ai/ai_profile.dart';
import 'shared_prefs_base_repository.dart';

class AIProfileRepository extends SharedPreferencesBaseRepository<AIProfile> {
  static const String _prefix = 'profile';
  static const String _selectedKey = 'ai_profile_settings:selected_id';

  AIProfileRepository(super.prefs);

  static Future<AIProfileRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AIProfileRepository(prefs);
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(AIProfile item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(AIProfile item) {
    return {
      'id': item.id,
      'name': item.name,
      'profileConversations': item.profileConversations,
      'conversationIds': item.conversationIds,
      'activeMCPServers': item.activeMCPServers.map((e) => e.toJson()).toList(),
      'activeBuiltInTools': item.activeBuiltInTools,
      'persistChatSelection': item.persistChatSelection,
      // RequestConfig fields
      'config': {
        'systemPrompt': item.config.systemPrompt,
        'enableStream': item.config.enableStream,
        'topP': item.config.topP,
        'topK': item.config.topK,
        'temperature': item.config.temperature,
        'contextWindow': item.config.contextWindow,
        'conversationLength': item.config.conversationLength,
        'maxTokens': item.config.maxTokens,
        'customThinkingTokens': item.config.customThinkingTokens,
        'thinkingLevel': item.config.thinkingLevel.name,
      },
    };
  }

  @override
  AIProfile deserializeFromFields(String id, Map<String, dynamic> fields) {
    final configMap = fields['config'] as Map<String, dynamic>? ?? {};

    return AIProfile(
      id: fields['id'] as String,
      name: fields['name'] as String,
      profileConversations: fields['profileConversations'] as bool? ?? false,
      conversationIds:
          (fields['conversationIds'] as List?)?.cast<String>() ?? const [],
      activeMCPServers:
          (fields['activeMCPServers'] as List?)
              ?.map((e) => ActiveMCPServer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeBuiltInTools:
          (fields['activeBuiltInTools'] as List?)?.cast<String>() ?? const [],
      persistChatSelection: fields['persistChatSelection'] as bool?,
      config: RequestConfig(
        systemPrompt: configMap['systemPrompt'] as String? ?? '',
        enableStream: configMap['enableStream'] as bool? ?? true,
        topP: configMap['topP'] as double?,
        topK: configMap['topK'] as double?,
        temperature: configMap['temperature'] as double?,
        contextWindow: configMap['contextWindow'] as int? ?? 60000,
        conversationLength: configMap['conversationLength'] as int? ?? 10,
        maxTokens: configMap['maxTokens'] as int? ?? 4000,
        customThinkingTokens: configMap['customThinkingTokens'] as int?,
        thinkingLevel: ThinkingLevel.values.firstWhere(
          (e) => e.name == configMap['thinkingLevel'] as String?,
          orElse: () => ThinkingLevel.auto,
        ),
      ),
    );
  }

  @override
  List<AIProfile> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      final defaultProfile = _createDefaultProfile();
      return [defaultProfile];
    }
    return items;
  }

  List<AIProfile> getProfiles() => getItems();

  // Reactive streams
  Stream<List<AIProfile>> get profilesStream => itemsStream;

  Stream<AIProfile> get selectedProfileStream {
    final controller = StreamController<AIProfile>.broadcast();
    StreamSubscription<void>? sub;
    controller.onListen = () async {
      final profile = await getOrInitSelectedProfile();
      controller.add(profile);
      sub = changes.listen((_) async {
        final p = await getOrInitSelectedProfile();
        controller.add(p);
      });
    };
    controller.onCancel = () async {
      await sub?.cancel();
      sub = null;
    };
    return controller.stream;
  }

  Future<void> addProfile(AIProfile profile) async {
    await saveItem(profile);
    // If no selection yet, select the newly added profile by default
    if (getSelectedProfileId() == null) {
      await setSelectedProfileId(profile.id);
    }
  }

  Future<void> updateProfile(AIProfile profile) async {
    await updateItem(profile);
  }

  Future<void> deleteProfile(String id) async {
    await deleteItem(id);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedProfileId();
    if (selectedId == id) {
      final allIds = getItemIds();

      if (allIds.isEmpty) {
        await prefs.remove(_selectedKey);
      } else {
        // Select the first available
        await setSelectedProfileId(allIds.first);
      }
    }
  }

  // --- Selection helpers ---

  String? getSelectedProfileId() => prefs.getString(_selectedKey);
  
  Future<void> setSelectedProfileId(String id) async {
    await prefs.setString(_selectedKey, id);
    // Notify listeners so selected profile updates propagate live
    changeNotifier.value++;
  }

  Future<AIProfile> getOrInitSelectedProfile() async {
    final selectedId = getSelectedProfileId();

    if (selectedId != null) {
      final profile = getItem(selectedId);
      if (profile != null) return profile;
    }

    // Fallback if selection is invalid or missing
    final allIds = getItemIds();
    if (allIds.isNotEmpty) {
      final firstProfile = getItem(allIds.first);
      if (firstProfile != null) {
        await setSelectedProfileId(firstProfile.id);
        return firstProfile;
      }
    }

    // Create default profile
    final defaultProfile = _createDefaultProfile();
    await saveItem(defaultProfile);
    await setSelectedProfileId(defaultProfile.id);
    return defaultProfile;
  }

  AIProfile _createDefaultProfile() {
    return AIProfile(
      id: const Uuid().v4(),
      name: 'Basic Profile',
      config: RequestConfig(systemPrompt: '', enableStream: true),
    );
  }
}
