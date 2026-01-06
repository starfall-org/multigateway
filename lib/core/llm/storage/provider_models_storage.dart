import '../../storage/base.dart';
import '../models/llm_provider_models.dart';

class LlmProviderModelsStorage extends HiveBaseStorage<LlmProviderModels> {
  static const String _prefix = 'provider_info';

  LlmProviderModelsStorage();

  static Future<LlmProviderModelsStorage> init() async {
    return LlmProviderModelsStorage();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(LlmProviderModels item) => item.id;

  @override
  Map<String, dynamic> serializeToFields(LlmProviderModels item) {
    return item.toJson();
  }

  @override
  LlmProviderModels deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return LlmProviderModels.fromJson(fields);
  }
}
