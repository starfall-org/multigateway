import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme.dart';
import 'base_repository.dart';

class ThemeRepository extends BaseRepository<ThemeSettings> {
  static const String _storageKey = 'theme_settings';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<ThemeSettings> themeNotifier = ValueNotifier(
    ThemeSettings.defaults(),
  );

  ThemeRepository(super.prefs) {
    _loadInitialTheme();
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static Future<ThemeRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeRepository(prefs);
  }

  @override
  String get storageKey => _storageKey;

  @override
  ThemeSettings deserializeItem(String json) =>
      ThemeSettings.fromJsonString(json);

  @override
  String serializeItem(ThemeSettings item) => item.toJsonString();

  // Single settings object, so ID is constant
  @override
  String getItemId(ThemeSettings item) => 'settings';

  Future<void> updateSettings(ThemeSettings settings) async {
    // We only ever store one item for settings
    final items = [settings];
    // This is a bit of a hack since base repo manages lists,
    // but works fine if we just treat it as a list of 1.
    // However, BaseRepository.saveItem expects generic ID.
    // Let's just override save logic for simplicity or use the list
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  ThemeSettings get currentTheme => themeNotifier.value;
}
