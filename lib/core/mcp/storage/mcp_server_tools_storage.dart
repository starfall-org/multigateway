import '../../storage/base.dart';
import '../models/mcp_server_tools.dart';

class McpServerToolsStorage extends HiveBaseStorage<McpServerTools> {
  static const String _prefix = 'provider_info';

  McpServerToolsStorage();

  static Future<McpServerToolsStorage> init() async {
    return McpServerToolsStorage();
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
