import 'dart:convert';

import 'provider.dart';

enum TTSServiceType { system, provider }

class SpeechService{
  final TextToSpeech tts;
  final SpeechToText stt;

  const SpeechService({
    


  })
}

class TextToSpeech {
  final String id;
  final String icon;
  final String name;
  final TTSServiceType type;
  final Provider? provider;
  final String? model;
  final String? voiceId;
  final Map<String, dynamic> settings;

  const TextToSpeech({
    required this.id,
    required this.icon,
    required this.name,
    required this.type,
    this.provider,
    this.model,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'type': type.name,
      'provider': provider?.name, // Serialize enum name
      'model': model,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory TextToSpeech.fromJson(Map<String, dynamic> json) {
    return TextToSpeech(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: TTSServiceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TTSServiceType.system,
      ),
      provider: json['provider'] != null
          ? Provider.getTypeByName(json['provider']) != null
                ? Provider(type: Provider.getTypeByName(json['provider'])!)
                : null
          : null,
      model: json['model'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TextToSpeech.fromJsonString(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw FormatException("Empty JSON string");
    }
    return TextToSpeech.fromJson(json.decode(jsonString));
  }
}


class SpeechToText{
  final String id;
  final String icon;
  final String name;
  final TTSServiceType type;
  final Provider? provider;
  final String? model;
  final String? voiceId;
  final Map<String, dynamic> settings;

  const SpeechToText({
    required this.id,
    required this.icon,
    required this.name,
    required this.type,
    this.provider,
    this.model,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'type': type.name,
      'provider': provider?.name, // Serialize enum name
      'model': model,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory SpeechToText.fromJson(Map<String, dynamic> json) {
    return SpeechToText(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: TTSServiceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TTSServiceType.system,
      ),
      provider: json['provider'] != null
          ? Provider.getTypeByName(json['provider']) != null
                ? Provider(type: Provider.getTypeByName(json['provider'])!)
                : null
          : null,
      model: json['model'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }
}
  