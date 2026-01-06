import 'package:json_annotation/json_annotation.dart';

part 'github_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GitHubModel {
  final String id;
  final String name;
  final List<String> supportedInputModalities;
  final List<String> supportedOutputModalities;
  final int maxInputTokens;
  final int maxOutputTokens;

  GitHubModel({
    required this.id,
    required this.name,
    required this.supportedInputModalities,
    required this.supportedOutputModalities,
    required this.maxInputTokens,
    required this.maxOutputTokens,
  });

  factory GitHubModel.fromJson(Map<String, dynamic> json) {
    return _$GitHubModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$GitHubModelToJson(this);
  }
}
