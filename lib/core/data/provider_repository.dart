import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider.dart';
import 'shared_prefs_base_repository.dart';

class ProviderRepository extends SharedPreferencesBaseRepository<Provider> {
  static const String _prefix = 'provider';

  ProviderRepository(super.prefs);

  static Future<ProviderRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderRepository(prefs);
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(Provider item) => item.name;

  @override
  Map<String, dynamic> serializeToFields(Provider item) {
    return item.toJson();
  }

  @override
  Provider deserializeFromFields(String id, Map<String, dynamic> fields) {
    return Provider.fromJson(fields);
  }

  List<Provider> getProviders() => getItems();

  /// Reactive stream of providers; emits immediately and on each change.
  Stream<List<Provider>> get providersStream => itemsStream;

  Future<void> addProvider(Provider provider) => saveItem(provider);

  Future<void> updateProvider(Provider provider) => saveItem(provider);

  Future<void> deleteProvider(String name) => deleteItem(name);
}
