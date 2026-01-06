import 'package:json_annotation/json_annotation.dart';

part 'ollama_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class OllamaModel {
  final String name;
  final String model;
  final String parameterSize;
  final String quantizationLevel;

  OllamaModel({
    required this.name,
    required this.model,
    required this.parameterSize,
    required this.quantizationLevel,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return _$OllamaModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$OllamaModelToJson(this);
  }
}
