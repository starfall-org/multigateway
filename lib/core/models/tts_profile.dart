import 'dart:convert';

enum TTSServiceType { system, provider }

class TTSProfile {
  final String id;
  final String name;
  final TTSServiceType type;
  final String? provider;
  final String? voiceId;
  final Map<String, dynamic> settings;

  TTSProfile({
    required this.id,
    required this.name,
    required this.type,
    this.provider,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'provider': provider,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory TTSProfile.fromJson(Map<String, dynamic> json) {
    return TTSProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TTSServiceType.values.firstWhere((e) => e.name == json['type']),
      provider: json['provider'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TTSProfile.fromJsonString(String jsonString) =>
      TTSProfile.fromJson(json.decode(jsonString));
}
