import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/domain/tts_profile.dart';

class TTSRepository {
  static const String _storageKey = 'tts_profiles';
  final SharedPreferences _prefs;

  TTSRepository(this._prefs);

  static Future<TTSRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return TTSRepository(prefs);
  }

  List<TTSProfile> getProfiles() {
    final List<String>? profilesJson = _prefs.getStringList(_storageKey);
    if (profilesJson == null || profilesJson.isEmpty) {
      return [];
    }
    return profilesJson.map((str) => TTSProfile.fromJsonString(str)).toList();
  }

  Future<void> addProfile(TTSProfile profile) async {
    final profiles = getProfiles();
    profiles.add(profile);
    await _saveProfiles(profiles);
  }

  Future<void> deleteProfile(String id) async {
    final profiles = getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _saveProfiles(profiles);
  }

  Future<void> _saveProfiles(List<TTSProfile> profiles) async {
    final List<String> profilesJson = profiles
        .map((p) => p.toJsonString())
        .toList();
    await _prefs.setStringList(_storageKey, profilesJson);
  }
}
