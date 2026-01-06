import 'package:json_annotation/json_annotation.dart';

part 'googleai_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GoogleAiModel {
  final String name;
  final String displayName;
  final int inputTokenLimit;
  final int outputTokenLimit;
  final List<String> supportedGenerationMethods;
  final bool thinking;
  final double temperature;
  final double maxTemperature;
  final double topP;
  final int topK;

  GoogleAiModel({
    required this.name,
    required this.displayName,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
    required this.supportedGenerationMethods,
    required this.thinking,
    required this.temperature,
    required this.maxTemperature,
    required this.topP,
    required this.topK,
  });

  factory GoogleAiModel.fromJson(Map<String, dynamic> json) {
    return _$GoogleAiModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$GoogleAiModelToJson(this);
  }
}
