import 'dart:async';
import '../../../shared/storage/base.dart';

import '../models/llm_provider/provider_info.dart';

class ProviderInfoStorage extends HiveBaseStorage<Provider> {
  static const String _prefix = 'provider';

  ProviderInfoStorage();

  static Future<ProviderInfoStorage> init() async {
    return ProviderInfoStorage();
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
