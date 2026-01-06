import 'package:multigateway/core/llm/models/llm_provider_config.dart';
import 'package:multigateway/core/storage/base.dart';

class LlmProviderConfigStorage extends HiveBaseStorage<LlmProviderConfig> {
  static const String _prefix = 'provider_info';

  LlmProviderConfigStorage();

  static Future<LlmProviderConfigStorage> init() async {
    return LlmProviderConfigStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(LlmProviderConfig item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(LlmProviderConfig item) {
    return item.toJson();
  }

  @override
  LlmProviderConfig deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return LlmProviderConfig.fromJson(fields);
  }
}
