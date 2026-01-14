import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/core/storage/base.dart';

class LlmProviderModelsStorage extends HiveBaseStorage<LlmProviderModels> {
  static const String _prefix = 'llm_provider_models';

  static LlmProviderModelsStorage? _instance;
  static Future<LlmProviderModelsStorage>? _instanceFuture;

  LlmProviderModelsStorage();

  static Future<LlmProviderModelsStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= init();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<LlmProviderModelsStorage> init() async {
    final instance = LlmProviderModelsStorage();
    await instance.ensureBoxReady();
    return instance;
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
