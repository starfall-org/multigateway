import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mcp/mcp_server.dart';
import 'shared_prefs_base_repository.dart';

class MCPRepository extends SharedPreferencesBaseRepository<MCPServer> {
  static const String _prefix = 'mcp';

  MCPRepository(super.prefs);

  static Future<MCPRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return MCPRepository(prefs);
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
