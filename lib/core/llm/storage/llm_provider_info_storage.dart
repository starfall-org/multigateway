import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/storage/base.dart';

class LlmProviderInfoStorage extends HiveBaseStorage<LlmProviderInfo> {
  static const String _prefix = 'llm_provider_info';

  static LlmProviderInfoStorage? _instance;

  LlmProviderInfoStorage();

  static LlmProviderInfoStorage get instance {
    _instance ??= LlmProviderInfoStorage();
    return _instance!;
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
