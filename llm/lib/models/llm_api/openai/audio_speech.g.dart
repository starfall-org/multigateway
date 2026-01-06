// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_speech.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiAudioSpeechRequest _$OpenAiAudioSpeechRequestFromJson(
  Map<String, dynamic> json,
) => OpenAiAudioSpeechRequest(
  model: json['model'] as String,
  input: json['input'] as String,
  voice: json['voice'] as String,
  responseFormat: json['response_format'] == null
      ? null
      : OpenAIAudioResponseFormat.fromJson(json['response_format'] as String),
  speed: (json['speed'] as num?)?.toDouble(),
);

Map<String, dynamic> _$OpenAiAudioSpeechRequestToJson(
  OpenAiAudioSpeechRequest instance,
) => <String, dynamic>{
  'model': instance.model,
  'input': instance.input,
  'voice': instance.voice,
  'response_format': instance.responseFormat?.toJson(),
  'speed': instance.speed,
};

OpenAiAudioSpeech _$OpenAiAudioSpeechFromJson(Map<String, dynamic> json) =>
    OpenAiAudioSpeech(audioContent: json['audio_content'] as String);

Map<String, dynamic> _$OpenAiAudioSpeechToJson(OpenAiAudioSpeech instance) =>
    <String, dynamic>{'audio_content': instance.audioContent};
