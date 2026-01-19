import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'speech_service.g.dart';

enum ServiceType { system, provider }

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class SpeechService {
  final String id;
  final String name;
  final String? icon;

  final TextToSpeech tts;
  final SpeechToText stt;

  const SpeechService({
    required this.id,
    required this.name,
    this.icon,
    required this.tts,
    required this.stt,
  });

  Map<String, dynamic> toJson() {
    return _$SpeechServiceToJson(this);
  }

  factory SpeechService.fromJson(Map<String, dynamic> json) {
    return _$SpeechServiceFromJson(json);
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TextToSpeech {
  final ServiceType type;
  final String? provider;
  final String? modelId;
  final String? voiceId;
  final Map<dynamic, dynamic> settings;

  const TextToSpeech({
    required this.type,
    this.provider,
    this.modelId,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return _$TextToSpeechToJson(this);
  }

  factory TextToSpeech.fromJson(Map<String, dynamic> json) {
    return _$TextToSpeechFromJson(json);
  }

  String toJsonString() => json.encode(toJson());

  factory TextToSpeech.fromJsonString(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw FormatException("Empty JSON string");
    }
    return TextToSpeech.fromJson(json.decode(jsonString));
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class SpeechToText {
  final ServiceType type;
  final String? provider;
  final String? modelId;
  final Map<dynamic, dynamic> settings;

  const SpeechToText({
    required this.type,
    this.provider,
    this.modelId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return _$SpeechToTextToJson(this);
  }

  factory SpeechToText.fromJson(Map<String, dynamic> json) {
    return _$SpeechToTextFromJson(json);
  }
}
