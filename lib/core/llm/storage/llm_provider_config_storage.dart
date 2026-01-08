import 'package:multigateway/core/llm/models/llm_provider_config.dart';
import 'package:multigateway/core/storage/base.dart';

class LlmProviderConfigStorage extends HiveBaseStorage<LlmProviderConfig> {
  static const String _prefix = 'llm_provider_config';

  static LlmProviderConfigStorage? _instance;

  LlmProviderConfigStorage();

  static LlmProviderConfigStorage get instance {
    _instance ??= LlmProviderConfigStorage();
    return _instance!;
  }

  static Future<LlmProviderConfigStorage> init() async {
    final instance = LlmProviderConfigStorage();
    await instance.ensureBoxReady();
    return instance;
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
