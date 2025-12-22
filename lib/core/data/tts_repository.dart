import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/speech_service.dart';
import 'shared_prefs_base_repository.dart';

class TTSRepository extends SharedPreferencesBaseRepository<SpeechService> {
  static const String _prefix = 'tts';

  TTSRepository(super.prefs);

  static Future<TTSRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return TTSRepository(prefs);
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(SpeechService item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(SpeechService item) {
    return {
      'id': item.id,
      'icon': item.icon,
      'name': item.name,
      'type': item.type.name,
      'provider': item.provider?.name,
      'model': item.model,
      'voiceId': item.voiceId,
      'settings': item.settings,
    };
  }

  @override
  SpeechService deserializeFromFields(String id, Map<String, dynamic> fields) {
    return SpeechService.fromJson(fields);
  }

  List<SpeechService> getProfiles() => getItems();

  /// Reactive stream of TTS profiles; emits immediately and on each change.
  Stream<List<SpeechService>> get profilesStream => itemsStream;

  Future<void> addProfile(SpeechService profile) => saveItem(profile);

  Future<void> deleteProfile(String id) => deleteItem(id);
}
