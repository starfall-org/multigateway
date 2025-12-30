import 'dart:async';
import '../../../shared/storage/base.dart';
import '../models/mcp_server.dart';

class MCPRepository extends HiveBaseStorage<MCPServer> {
  static const String _prefix = 'mcp';

  MCPRepository();

  static Future<MCPRepository> init() async {
    return MCPRepository();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(MCPServer item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(MCPServer item) {
    return item.toJson();
  }

  @override
  MCPServer deserializeFromFields(String id, Map<String, dynamic> fields) {
    return MCPServer.fromJson(fields);
  }

  /// Get all servers
  List<MCPServer> getMCPServers() => getItems();

  /// Reactive stream of MCP servers; emits immediately and on each change.
  Stream<List<MCPServer>> get mcpServersStream => itemsStream;
}
