import 'package:json_annotation/json_annotation.dart';

import 'package:llm/models/llm_model/basic_model.dart';

part 'models.g.dart';

@JsonSerializable()
class OpenAiModels {
  final String object;
  final List<BasicModel> data;

  OpenAiModels({required this.object, required this.data});

  factory OpenAiModels.fromJson(Map<String, dynamic> json) =>
      _$OpenAiModelsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiModelsToJson(this);

  @override
  String toString() {
    return 'OpenAiModels(object: $object, data: $data)';
  }
}
