import 'dart:convert';

enum TTSServiceType { system, provider, elevenLabs }

class TTSProfile {
  final String id;
  final String name;
  final TTSServiceType type;
  final String? providerId;
  final String? apiKey;
  final String? voiceId;
  final Map<String, dynamic> settings;

  TTSProfile({
    required this.id,
    required this.name,
    required this.type,
    this.providerId,
    this.apiKey,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'providerId': providerId,
      'apiKey': apiKey,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory TTSProfile.fromJson(Map<String, dynamic> json) {
    return TTSProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TTSServiceType.values.firstWhere((e) => e.name == json['type']),
      providerId: json['providerId'] as String?,
      apiKey: json['apiKey'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TTSProfile.fromJsonString(String jsonString) =>
      TTSProfile.fromJson(json.decode(jsonString));
}
