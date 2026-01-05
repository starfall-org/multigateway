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
    return BasicModel(
      id: json['id'],
      displayName: json['display_name'] ?? json['id'],
      ownedBy:
          json['owned_by'] ??
          (json['display_name'] != null ? 'anthropic' : 'unknown'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'display_name': displayName, 'owned_by': ownedBy};
  }

  @override
  String toString() {
    return 'BasicModel(id: $id, displayName: $displayName, ownedBy: $ownedBy)';
  }
}
