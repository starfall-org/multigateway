import 'dart:async';

import 'package:multigateway/core/speech/models/speech_service.dart';
import 'package:multigateway/core/storage/base.dart';

class SpeechServiceStorage extends HiveBaseStorage<SpeechService> {
  static const String _prefix = 'tts';

  SpeechServiceStorage();

  static Future<SpeechServiceStorage> init() async {
    return SpeechServiceStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(SpeechService item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(SpeechService item) {
    return item.toJson();
  }

  @override
  SpeechService deserializeFromFields(String id, Map<String, dynamic> fields) {
    // Normalize persisted data to current SpeechService schema
    // Case A: New schema already persisted with nested 'tts' and 'stt'
    if (fields.containsKey('tts') && fields.containsKey('stt')) {
      return SpeechService.fromJson(fields);
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
}
