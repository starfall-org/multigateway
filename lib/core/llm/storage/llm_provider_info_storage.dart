import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/storage/base.dart';

class LlmProviderInfoStorage extends HiveBaseStorage<LlmProviderInfo> {
  static const String _prefix = 'llm_provider_info';

  LlmProviderInfoStorage();

  static Future<LlmProviderInfoStorage> init() async {
    return LlmProviderInfoStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(LlmProviderInfo item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(LlmProviderInfo item) {
    return item.toJson();
  }

  @override
  LlmProviderInfo deserializeFromFields(String id, Map<String, dynamic> fields) {
    return LlmProviderInfo.fromJson(fields);
  }
}
