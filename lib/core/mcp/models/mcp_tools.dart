import 'package:json_annotation/json_annotation.dart';

part 'mcp_tools.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpToolsList {
  final String id;
  final String name;
  List<Map<String, dynamic>> tools;

  McpToolsList(this.id, this.name, this.tools);

  factory McpToolsList.fromJson(Map<String, dynamic> json) =>
      _$McpToolsListFromJson(json);

  Map<String, dynamic> toJson() => _$McpToolsListToJson(this);
}
