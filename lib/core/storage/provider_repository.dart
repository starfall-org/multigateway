import 'package:ai_gateway/core/models/settings/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base_repository.dart';

class ProviderRepository extends BaseRepository<LLMProvider> {
  static const String _storageKey = 'providers';

  ProviderRepository(super.prefs);

  static Future<ProviderRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  LLMProvider deserializeItem(String json) => LLMProvider.fromJsonString(json);

  @override
  String serializeItem(LLMProvider item) => item.toJsonString();

  @override
  String getItemId(LLMProvider item) => item.id;

  List<LLMProvider> getProviders() => getItems();

  Future<void> addProvider(LLMProvider provider) => saveItem(provider);

  Future<void> updateProvider(LLMProvider provider) => saveItem(provider);

  Future<void> deleteProvider(String id) => deleteItem(id);
}
