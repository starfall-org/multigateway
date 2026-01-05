import 'package:json_annotation/json_annotation.dart';

part 'mcp_jsonrpc.g.dart';

@JsonSerializable()
class MCPRequest {
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  MCPRequest({
    required this.id,
    required this.method,
    this.params,
  });

  factory MCPRequest.fromJson(Map<String, dynamic> json) =>
      _$MCPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MCPRequestToJson(this);
}

@JsonSerializable()
class MCPNotification {
  final String method;
  final Map<String, dynamic>? params;

  MCPNotification({
    required this.method,
    this.params,
  });

  factory MCPNotification.fromJson(Map<String, dynamic> json) =>
      _$MCPNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$MCPNotificationToJson(this);
}

@JsonSerializable()
class MCPResponse {
  final dynamic id;
  final dynamic result;
  final MCPError? error;

  MCPResponse({
    required this.id,
    this.result,
    this.error,
  });

  factory MCPResponse.fromJson(Map<String, dynamic> json) =>
      _$MCPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MCPResponseToJson(this);
}

@JsonSerializable()
class MCPError {
  final int code;
  final String message;
  final dynamic data;

  MCPError({
    required this.code,
    required this.message,
    this.data,
  });

  factory MCPError.fromJson(Map<String, dynamic> json) =>
      _$MCPErrorFromJson(json);

  Map<String, dynamic> toJson() => _$MCPErrorToJson(this);
}
