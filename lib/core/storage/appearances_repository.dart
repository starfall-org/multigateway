import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/appearances.dart';
import 'base_repository.dart';

class AppearancesRepository extends BaseRepository<Appearances> {
  static const String _boxName = 'theme_settings';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<Appearances> themeNotifier = ValueNotifier(
    Appearances.defaults(),
  );

  AppearancesRepository(super.box) {
    _loadInitialTheme();
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static AppearancesRepository? _instance;

  static Future<AppearancesRepository> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final box = await Hive.openBox<String>(_boxName);
    _instance = AppearancesRepository(box);
    return _instance!;
  }

  static AppearancesRepository get instance {
    if (_instance == null) {
      throw Exception('AppearancesRepository not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get boxName => _boxName;

  @override
  Appearances deserializeItem(String json) =>
      Appearances.fromJsonString(json);

  @override
  String serializeItem(Appearances item) => item.toJsonString();

  // Single settings object, so ID is constant
  @override
  String getItemId(Appearances item) => 'settings';

  Future<void> updateSettings(Appearances settings) async {
    // We only ever store one item for settings
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  Appearances get currentTheme => themeNotifier.value;
}
