import 'dart:async';
import 'base.dart';

import '../models/ai/provider.dart';


class ProviderRepository extends SharedPreferencesBaseRepository<Provider> {
  static const String _prefix = 'provider';

  ProviderRepository();

  static Future<ProviderRepository> init() async {
    return ProviderRepository();
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(Provider item) => item.id;

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

  Future<void> deleteProvider(String id) => deleteItem(id);
}
