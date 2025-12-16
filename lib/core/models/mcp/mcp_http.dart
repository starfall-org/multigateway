/// Configuration for HTTP-based transports (SSE, Streamable HTTP)
class MCPHttpConfig {
  /// Server URL endpoint
  final String url;

  /// Optional headers for authentication or other purposes
  final Map<String, String>? headers;

  const MCPHttpConfig({required this.url, this.headers});

  Map<String, dynamic> toJson() {
    return {'url': url, if (headers != null) 'headers': headers};
  }

  factory MCPHttpConfig.fromJson(Map<String, dynamic> json) {
    return MCPHttpConfig(
      url: json['url'] as String,
      headers: (json['headers'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }
}
