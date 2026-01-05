import 'package:json_annotation/json_annotation.dart';

part 'mcp_http.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MCPHttpConfig {
  final String url;
  final Map<String, String>? headers;

  const MCPHttpConfig({required this.url, this.headers});

  factory MCPHttpConfig.fromJson(Map<String, dynamic> json) =>
      _$MCPHttpConfigFromJson(json);

  Map<String, dynamic> toJson() => _$MCPHttpConfigToJson(this);
}
