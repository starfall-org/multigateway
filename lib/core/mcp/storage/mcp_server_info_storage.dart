import 'package:multigateway/core/mcp/models/mcp_info.dart';
import 'package:multigateway/core/storage/base.dart';

class McpInfoStorage extends HiveBaseStorage<McpInfo> {
  static const String _prefix = 'mcp_server_info';

  static McpInfoStorage? _instance;
  static Future<McpInfoStorage>? _instanceFuture;

  McpInfoStorage();

  static Future<McpInfoStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<McpInfoStorage> init() async {
    final instance = McpInfoStorage();
    await instance.ensureBoxReady();
    return instance;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(McpInfo item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(McpInfo item) {
    return item.toJson();
  }

  @override
  McpInfo deserializeFromFields(String id, Map<String, dynamic> fields) {
    return McpInfo.fromJson(fields);
  }
}
