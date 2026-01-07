import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/core/profile/models/chat_profile.dart';
import 'package:multigateway/core/storage/base.dart';
import 'package:uuid/uuid.dart';

class ChatProfileStorage extends HiveBaseStorage<ChatProfile> {
  static const String _prefix = 'chat_profile';
  static const String _selectedKey = '__selected_id__';

  static ChatProfileStorage? _instance;

  ChatProfileStorage();

  static ChatProfileStorage get instance {
    _instance ??= ChatProfileStorage();
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(ChatProfile item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(ChatProfile item) {
    return item.toJson();
  }

  @override
  ChatProfile deserializeFromFields(String id, Map<String, dynamic> fields) {
    return ChatProfile.fromJson(fields);
  }

  @override
  List<ChatProfile> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      final defaultProfile = _createDefaultProfile();
      return [defaultProfile];
    }
    return items;
  }

  // Reactive streams
  Stream<ChatProfile> get selectedProfileStream {
    final controller = StreamController<ChatProfile>.broadcast();
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

  // --- Selection helpers ---

  /// Override deleteItem to maintain valid selection after deletion
  @override
  Future<void> deleteItem(String id) async {
    await super.deleteItem(id);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedProfileId();
    if (selectedId == id) {
      final allIds = getItemIds();

      if (allIds.isEmpty) {
        final boxName = 'storage_$_prefix';
        final box = Hive.isBoxOpen(boxName)
            ? Hive.box(boxName)
            : await Hive.openBox(boxName);
        await box.delete(_selectedKey);
      } else {
        // Select the first available
        await setSelectedProfileId(allIds.first);
      }
    }
  }

  /// Override saveItem to auto-select first profile if none selected
  @override
  Future<void> saveItem(ChatProfile profile) async {
    await super.saveItem(profile);
    // If no selection yet, select the newly added profile by default
    if (getSelectedProfileId() == null) {
      await setSelectedProfileId(profile.id);
    }
  }

  String? getSelectedProfileId() {
    final boxName = 'storage_$_prefix';
    if (!Hive.isBoxOpen(boxName)) return null;
    final box = Hive.box(boxName);
    return box.get(_selectedKey) as String?;
  }

  Future<void> setSelectedProfileId(String id) async {
    final boxName = 'storage_$_prefix';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.put(_selectedKey, id);
    // Notify listeners so selected profile updates propagate live
    changeNotifier.value++;
  }

  Future<ChatProfile> getOrInitSelectedProfile() async {
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

  ChatProfile _createDefaultProfile() {
    return ChatProfile(
      id: const Uuid().v4(),
      name: 'Default Profile',
      config: LlmChatConfig(systemPrompt: '', enableStream: true),
    );
  }
}
