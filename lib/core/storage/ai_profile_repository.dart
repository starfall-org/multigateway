import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/ai/ai_profile.dart';
import 'base_repository.dart';

class AIProfileRepository extends BaseRepository<AIProfile> {
  static const String _boxName = 'ai_profiles';
  static const String _selectedKey = 'selected_profile_id';

  // We need a separate box for simple key-value settings like 'selected_profile_id'
  // Or we can store it in the same box with a special key if we are careful,
  // but BaseRepository assumes all values are T.
  // Better to use a separate settings box or stick to SharedPreferences for settings.
  // Since we are migrating to Hive, let's use a settings box.
  final Box settingsBox;

  AIProfileRepository(super.box, this.settingsBox);

  static Future<AIProfileRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    final settingsBox = await Hive.openBox('ai_profile_settings');
    return AIProfileRepository(box, settingsBox);
  }

  @override
  String get boxName => _boxName;

  @override
  AIProfile deserializeItem(String json) => AIProfile.fromJsonString(json);

  @override
  String serializeItem(AIProfile item) => item.toJsonString();

  @override
  String getItemId(AIProfile item) => item.id;

  @override
  List<AIProfile> getItems() {
    final items = super.getItems();
    if (items.isEmpty) {
      final defaultProfile = _createDefaultProfile();
      // We can't nicely call async saveItem here since this is sync.
      // But we can construct the list.
      // Ideally, the initialization of default profile should be done in 'init' or async method.
      // For now, we return empty or default, but persisting it synchronously is tricky with Hive if we want to stick to the pattern.
      // Actually Hive writes are async (put) but can be 'awaited'.
      // Let's just return the default profile and rely on the caller or 'getOrInitSelectedProfile' to save it.
      return [defaultProfile];
    }
    return items;
  }

  List<AIProfile> getProfiles() => getItems();

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
      // getItems might return default profile if empty, but that's a transient object.
      // Check box values directly or use getItems filtering.

      // If we just deleted the last one from box, getItems() returns [default] (unsaved).
      if (box.isEmpty) {
        await settingsBox.delete(_selectedKey);
      } else {
        // Select the first available
        final firstKey = box.keys.first;
        await setSelectedProfileId(firstKey.toString());
      }
    }
  }

  // --- Selection helpers ---

  String? getSelectedProfileId() => settingsBox.get(_selectedKey) as String?;

  Future<void> setSelectedProfileId(String id) async {
    await settingsBox.put(_selectedKey, id);
  }

  Future<AIProfile> getOrInitSelectedProfile() async {
    final selectedId = getSelectedProfileId();

    if (selectedId != null) {
      final profile = getItem(selectedId);
      if (profile != null) return profile;
    }

    // Fallback if selection is invalid or missing
    if (box.isNotEmpty) {
      final firstProfile = deserializeItem(box.values.first);
      await setSelectedProfileId(firstProfile.id);
      return firstProfile;
    } else {
      final defaultProfile = _createDefaultProfile();
      await saveItem(defaultProfile);
      await setSelectedProfileId(defaultProfile.id);
      return defaultProfile;
    }
  }

  AIProfile _createDefaultProfile() {
    return AIProfile(
      id: const Uuid().v4(),
      name: 'Basic Profile',
      config: RequestConfig(systemPrompt: '', enableStream: true),
    );
  }
}
