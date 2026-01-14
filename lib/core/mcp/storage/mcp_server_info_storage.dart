import 'package:multigateway/core/mcp/models/mcp_server_info.dart';
import 'package:multigateway/core/storage/base.dart';

class McpServerInfoStorage extends HiveBaseStorage<McpServerInfo> {
  static const String _prefix = 'mcp_server_info';

  static McpServerInfoStorage? _instance;
  static Future<McpServerInfoStorage>? _instanceFuture;

  McpServerInfoStorage();

  static Future<McpServerInfoStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<McpServerInfoStorage> init() async {
    final instance = McpServerInfoStorage();
    await instance.ensureBoxReady();
    return instance;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(McpServerInfo item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(McpServerInfo item) {
    return item.toJson();
  }

  @override
  McpServerInfo deserializeFromFields(String id, Map<String, dynamic> fields) {
    return McpServerInfo.fromJson(fields);
  }
}
