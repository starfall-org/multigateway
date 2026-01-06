import 'dart:async';
import '../../storage/base.dart';
import '../models/speech_service.dart';

class TTSRepository extends HiveBaseStorage<SpeechService> {
  static const String _prefix = 'tts';

  TTSRepository();

  static Future<TTSRepository> init() async {
    return TTSRepository();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(SpeechService item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(SpeechService item) {
    return {
      'id': item.id,
      'name': item.name,
      'icon': item.icon,
      'tts': item.tts.toJson(),
      'stt': item.stt.toJson(),
    };
  }

  @override
  SpeechService deserializeFromFields(String id, Map<String, dynamic> fields) {
    // Normalize persisted data to current SpeechService schema
    // Case A: New schema already persisted with nested 'tts' and 'stt'
    if (fields.containsKey('tts') && fields.containsKey('stt')) {
      return SpeechService.fromJson({
        'id': (fields['id'] ?? id) as String,
        'name': (fields['name'] as String?) ?? '',
        'icon': fields['icon'] as String?,
        'tts': Map<String, dynamic>.from(fields['tts'] as Map),
        'stt': Map<String, dynamic>.from(fields['stt'] as Map),
      });
    }

    // Case B: Legacy flat schema (single TTS-like fields at top-level)
    final String name = (fields['name'] as String?) ?? '';
    final String? icon = fields['icon'] as String?;
    final String? provider = fields['provider'] as String?;
    final String? model = fields['model'] as String?;
    final String? voiceId = fields['voiceId'] as String?;
    final Map<String, dynamic> settings = (fields['settings'] is Map)
        ? Map<String, dynamic>.from(fields['settings'] as Map)
        : <String, dynamic>{};

    final String? typeStr = fields['type'] as String?;
    final ServiceType ttsType = ServiceType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ServiceType.system,
    );

    final Map<String, dynamic> ttsJson = {
      'id': id,
      'icon': icon ?? '',
      'name': name.isNotEmpty ? name : 'TTS',
      'type': ttsType.name,
      'provider': provider,
      'model': model,
      'voiceId': voiceId,
      'settings': settings,
    };

    // Create a minimal STT placeholder to satisfy the current model
    final Map<String, dynamic> sttJson = {
      'id': id,
      'icon': icon ?? '',
      'name': name.isNotEmpty ? name : 'STT',
      'type': ServiceType.system.name,
      'provider': null,
      'model': null,
      'voiceId': null,
      'settings': <String, dynamic>{},
    };

    return SpeechService.fromJson({
      'id': (fields['id'] ?? id) as String,
      'name': name,
      'icon': icon,
      'tts': ttsJson,
      'stt': sttJson,
    });
  }

  List<SpeechService> getProfiles() => getItems();

  /// Reactive stream of TTS profiles; emits immediately and on each change.
  Stream<List<SpeechService>> get profilesStream => itemsStream;

  Future<void> addProfile(SpeechService profile) => saveItem(profile);

  Future<void> deleteProfile(String id) => deleteItem(id);
}
