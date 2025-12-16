import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider.dart';
import 'base_repository.dart';

class ProviderRepository extends BaseRepository<Provider> {
  static const String _storageKey = 'providers';

  ProviderRepository(super.prefs);

  static Future<ProviderRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  Provider deserializeItem(String json) => Provider.fromJsonString(json);

  @override
  String serializeItem(Provider item) => item.toJsonString();

  @override
  String getItemId(Provider item) => item.name;

  List<Provider> getProviders() => getItems();

  Future<void> addProvider(Provider provider) => saveItem(provider);

  Future<void> updateProvider(Provider provider) => saveItem(provider);

  Future<void> deleteProvider(String name) => deleteItem(name);
}
