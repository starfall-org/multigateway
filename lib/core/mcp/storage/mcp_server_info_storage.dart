import 'package:multigateway/core/mcp/models/mcp_server_info.dart';
import 'package:multigateway/core/storage/base.dart';

class McpServerInfoStorage extends HiveBaseStorage<McpServerInfo> {
  static const String _prefix = 'mcp_server_info';

  static McpServerInfoStorage? _instance;

  McpServerInfoStorage();

  static McpServerInfoStorage get instance {
    _instance ??= McpServerInfoStorage();
    return _instance!;
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
