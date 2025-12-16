/// Configuration for stdio transport
/// Used when MCP server runs as a local subprocess
class MCPStdioConfig {
  /// Command to execute (e.g., 'npx', 'python', 'node')
  final String command;

  /// Arguments to pass to the command
  final List<String> args;

  /// Environment variables for the subprocess
  final Map<String, String>? env;

  /// Working directory for the subprocess
  final String? cwd;

  const MCPStdioConfig({
    required this.command,
    this.args = const [],
    this.env,
    this.cwd,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'args': args,
      if (env != null) 'env': env,
      if (cwd != null) 'cwd': cwd,
    };
  }

  factory MCPStdioConfig.fromJson(Map<String, dynamic> json) {
    return MCPStdioConfig(
      command: json['command'] as String,
      args: (json['args'] as List?)?.cast<String>() ?? [],
      env: (json['env'] as Map<String, dynamic>?)?.cast<String, String>(),
      cwd: json['cwd'] as String?,
    );
  }
}
