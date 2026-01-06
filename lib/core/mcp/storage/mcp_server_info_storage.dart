import '../../storage/base.dart';
import '../models/mcp_server_info.dart';

class McpServerInfoStorage extends HiveBaseStorage<McpServerInfo> {
  static const String _prefix = 'provider_info';

  McpServerInfoStorage();

  static Future<McpServerInfoStorage> init() async {
    return McpServerInfoStorage();
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
  McpServerInfo deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return McpServerInfo.fromJson(fields);
  }
}
