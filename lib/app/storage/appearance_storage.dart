import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/storage/shared_prefs_base.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

class AppearanceStorage extends SharedPreferencesBase<AppearanceSetting> {
  static const String _prefix = 'appearance';

  final theme = signal<AppearanceSetting>(AppearanceSetting.defaults());

  AppearanceStorage(super.prefs) {
    _loadInitialTheme();
    changes.listen((_) {
      final items = getItems();
      theme.value = items.isNotEmpty
          ? items.first
          : AppearanceSetting.defaults();
    });
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      theme.value = items.first;
    }
  }

  static Future<AppearanceStorage>? _instanceFuture;
  static AppearanceStorage? _instance;

  static Future<AppearanceStorage> get instance async {
    if (_instance != null) return _instance!;
    _instanceFuture ??= _createInstance();
    _instance = await _instanceFuture!;
    return _instance!;
  }

  static Future<AppearanceStorage> _createInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return AppearanceStorage(prefs);
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(AppearanceSetting item) => 'settings';

  @override
  Map<String, dynamic> serializeToFields(AppearanceSetting item) {
    return item.toJson();
  }

  @override
  AppearanceSetting deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return AppearanceSetting.fromJson(fields);
  }

  Future<void> updateSettings(AppearanceSetting settings) async {
    await saveItem(settings);
    theme.value = settings;
  }
}
