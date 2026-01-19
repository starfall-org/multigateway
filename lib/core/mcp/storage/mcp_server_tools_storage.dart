import 'package:multigateway/core/mcp/models/mcp_tools.dart';
import 'package:multigateway/core/storage/base.dart';

class McpToolsListStorage extends HiveBaseStorage<McpToolsList> {
  static const String _prefix = 'mcp_server_tools';

  static McpToolsListStorage? _instance;
  static Future<McpToolsListStorage>? _instanceFuture;

  McpToolsListStorage();

  static Future<McpToolsListStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<McpToolsListStorage> init() async {
    final instance = McpToolsListStorage();
    await instance.ensureBoxReady();
    return instance;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(McpToolsList item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(McpToolsList item) {
    return item.toJson();
  }

  @override
  McpToolsList deserializeFromFields(String id, Map<String, dynamic> fields) {
    return McpToolsList.fromJson(fields);
  }
}
