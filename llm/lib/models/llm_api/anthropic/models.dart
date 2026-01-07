import 'package:json_annotation/json_annotation.dart';

import 'package:llm/models/llm_model/basic_model.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AnthropicModels {
  final List<BasicModel> data;
  final String firstId;
  final bool hasMore;
  final String lastId;

  AnthropicModels({
    required this.data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
  });

  factory AnthropicModels.fromJson(Map<String, dynamic> json) =>
      _$AnthropicModelsFromJson(json);

  Map<String, dynamic> toJson() => _$AnthropicModelsToJson(this);
}
