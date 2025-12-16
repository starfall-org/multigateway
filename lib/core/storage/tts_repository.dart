import 'package:shared_preferences/shared_preferences.dart';
import '../models/tts_profile.dart';
import 'base_repository.dart';

class TTSRepository extends BaseRepository<TTSProfile> {
  static const String _storageKey = 'tts_profiles';

  TTSRepository(super.prefs);

  static Future<TTSRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return TTSRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  TTSProfile deserializeItem(String json) => TTSProfile.fromJsonString(json);

  @override
  String serializeItem(TTSProfile item) => item.toJsonString();

  @override
  String getItemId(TTSProfile item) => item.id;

  List<TTSProfile> getProfiles() => getItems();

  Future<void> addProfile(TTSProfile profile) => saveItem(profile);

  Future<void> deleteProfile(String id) => deleteItem(id);
}
