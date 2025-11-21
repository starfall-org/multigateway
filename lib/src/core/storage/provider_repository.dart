import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/domain/provider.dart';

class ProviderRepository {
  static const String _storageKey = 'providers';
  final SharedPreferences _prefs;

  ProviderRepository(this._prefs);

  static Future<ProviderRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderRepository(prefs);
  }

  List<LLMProvider> getProviders() {
    final List<String>? providersJson = _prefs.getStringList(_storageKey);
    if (providersJson == null || providersJson.isEmpty) {
      return [];
    }
    return providersJson.map((str) => LLMProvider.fromJsonString(str)).toList();
  }

  Future<void> addProvider(LLMProvider provider) async {
    final providers = getProviders();
    providers.add(provider);
    await _saveProviders(providers);
  }

  Future<void> deleteProvider(String id) async {
    final providers = getProviders();
    providers.removeWhere((p) => p.id == id);
    await _saveProviders(providers);
  }

  Future<void> updateProvider(LLMProvider provider) async {
    final providers = getProviders();
    final index = providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      providers[index] = provider;
      await _saveProviders(providers);
    }
  }

  Future<void> _saveProviders(List<LLMProvider> providers) async {
    final List<String> providersJson = providers
        .map((p) => p.toJsonString())
        .toList();
    await _prefs.setStringList(_storageKey, providersJson);
  }
}
