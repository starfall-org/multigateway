import '../../storage/base.dart';
import '../models/llm_provider_info.dart';

class LlmProviderInfoStorage extends HiveBaseStorage<LlmProviderInfo> {
  static const String _prefix = 'provider_info';

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
