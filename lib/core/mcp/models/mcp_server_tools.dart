import 'package:json_annotation/json_annotation.dart';

part 'mcp_server_tools.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpServerTools {
  final String id;
  final String name;
  List<McpTool> tools;

  McpServerTools(this.id, this.name, this.tools);

  factory McpServerTools.fromJson(Map<String, dynamic> json) =>
      _$McpServerToolsFromJson(json);

  // _$McpServerToolsFromJson(json);

  Map<String, dynamic> toJson() => _$McpServerToolsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpTool {
  String name;
  String description;
  List<McpToolParam> params;

  McpTool(this.name, this.description, this.params);

  factory McpTool.fromJson(Map<String, dynamic> json) =>
      _$McpToolFromJson(json);
  // _$McpToolFromJson(json);

  Map<String, dynamic> toJson() => _$McpToolToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class McpToolParam {
  String name;
  String value;
  String description;
  McpToolParam(this.name, this.value, this.description);

  factory McpToolParam.fromJson(Map<String, dynamic> json) =>
      _$McpToolParamFromJson(json);

  Map<String, dynamic> toJson() => _$McpToolParamToJson(this);
}
