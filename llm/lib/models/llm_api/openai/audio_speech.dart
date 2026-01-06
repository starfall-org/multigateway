import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audio_speech.g.dart';

/// Enum cho tham số response_format
@JsonEnum(valueField: 'value')
enum OpenAIAudioResponseFormat {
  mp3('mp3'),
  opus('opus'),
  aac('aac'),
  flac('flac'),
  wav('wav'),
  pcm('pcm');

  final String value;
  const OpenAIAudioResponseFormat(this.value);

  factory OpenAIAudioResponseFormat.fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => throw ArgumentError('Invalid response format: $json'),
  );

  String toJson() => value;
}

/// Request model cho API /v1/audio/speech
@immutable
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiAudioSpeechRequest {
  final String model;
  final String input;
  final String voice;
  final OpenAIAudioResponseFormat? responseFormat;
  final double? speed;

  const OpenAiAudioSpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
    this.responseFormat,
    this.speed,
  });

  factory OpenAiAudioSpeechRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAiAudioSpeechRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiAudioSpeechRequestToJson(this);

  @override
  String toString() => 'Request(model: $model, input: $input, voice: $voice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAiAudioSpeechRequest &&
        other.model == model &&
        other.input == input &&
        other.voice == voice &&
        other.responseFormat == responseFormat &&
        other.speed == speed;
  }

  @override
  int get hashCode => Object.hash(model, input, voice, responseFormat, speed);
}

/// Response model cho API /v1/audio/speech
@immutable
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OpenAiAudioSpeech {
  final String audioContent;

  const OpenAiAudioSpeech({required this.audioContent});

  factory OpenAiAudioSpeech.fromJson(Map<String, dynamic> json) =>
      _$OpenAiAudioSpeechFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiAudioSpeechToJson(this);

  @override
  String toString() => '(audioContent: $audioContent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAiAudioSpeech && other.audioContent == audioContent;
  }

  @override
  int get hashCode => audioContent.hashCode;
}
