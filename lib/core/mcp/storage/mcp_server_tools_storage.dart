import 'package:multigateway/core/mcp/models/mcp_server_tools.dart';
import 'package:multigateway/core/storage/base.dart';

class McpServerToolsStorage extends HiveBaseStorage<McpServerTools> {
  static const String _prefix = 'mcp_server_tools';

  static McpServerToolsStorage? _instance;
  static Future<McpServerToolsStorage>? _instanceFuture;

  McpServerToolsStorage();

  static Future<McpServerToolsStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<McpServerToolsStorage> init() async {
    final instance = McpServerToolsStorage();
    await instance.ensureBoxReady();
    return instance;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(McpServerTools item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(McpServerTools item) {
    return item.toJson();
  }

  @override
  McpServerTools deserializeFromFields(String id, Map<String, dynamic> fields) {
    return McpServerTools.fromJson(fields);
  }
}
