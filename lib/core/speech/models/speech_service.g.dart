// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpeechService _$SpeechServiceFromJson(Map<String, dynamic> json) =>
    SpeechService(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      tts: TextToSpeech.fromJson(json['tts'] as Map<String, dynamic>),
      stt: SpeechToText.fromJson(json['stt'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SpeechServiceToJson(SpeechService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'tts': instance.tts,
      'stt': instance.stt,
    };

TextToSpeech _$TextToSpeechFromJson(Map<String, dynamic> json) => TextToSpeech(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ServiceTypeEnumMap, json['type']),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      voiceId: json['voice_id'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TextToSpeechToJson(TextToSpeech instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'type': _$ServiceTypeEnumMap[instance.type]!,
      'provider': instance.provider,
      'model': instance.model,
      'voice_id': instance.voiceId,
      'settings': instance.settings,
    };

const _$ServiceTypeEnumMap = {
  ServiceType.system: 'system',
  ServiceType.provider: 'provider',
};

SpeechToText _$SpeechToTextFromJson(Map<String, dynamic> json) => SpeechToText(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$ServiceTypeEnumMap, json['type']),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      voiceId: json['voice_id'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SpeechToTextToJson(SpeechToText instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'type': _$ServiceTypeEnumMap[instance.type]!,
      'provider': instance.provider,
      'model': instance.model,
      'voice_id': instance.voiceId,
      'settings': instance.settings,
    };
