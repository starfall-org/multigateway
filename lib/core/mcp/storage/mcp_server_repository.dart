import 'dart:async';
import 'package:mcp/mcp.dart';
import 'package:multigateway/core/storage/base.dart';

/// Repository for managing MCP servers
/// Wraps McpServer from mcp package with Hive persistence
class McpServerStorage extends HiveBaseStorage<McpServer> {
  static const String _prefix = 'mcp_servers';

  McpServerStorage();

  static Future<McpServerStorage> init() async {
    return McpServerStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(McpServer item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(McpServer item) {
    return item.toJson();
  }

  @override
  McpServer deserializeFromFields(String id, Map<String, dynamic> fields) {
    return McpServer.fromJson(fields);
  }
}
