import 'package:multigateway/core/mcp/models/mcp_server_tools.dart';
import 'package:multigateway/core/storage/base.dart';

class McpServerToolsStorage extends HiveBaseStorage<McpServerTools> {
  static const String _prefix = 'mcp_server_tools';

  static McpServerToolsStorage? _instance;

  McpServerToolsStorage();

  static McpServerToolsStorage get instance {
    _instance ??= McpServerToolsStorage();
    return _instance!;
  }

  static Future<McpServerToolsStorage> init() async => instance;

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
