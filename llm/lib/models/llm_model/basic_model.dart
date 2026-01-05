import 'package:json_annotation/json_annotation.dart';

part 'basic_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BasicModel {
  final String id;
  final String displayName;
  final String ownedBy;

  BasicModel({
    required this.id,
    required this.displayName,
    required this.ownedBy,
  });

  factory BasicModel.fromJson(Map<String, dynamic> json) {
    return _$BasicModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$BasicModelToJson(this);
  }

  @override
  String toString() {
    return 'BasicModel(id: $id, displayName: $displayName, ownedBy: $ownedBy)';
  }
}
