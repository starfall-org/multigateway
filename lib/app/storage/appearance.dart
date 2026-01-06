import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/appearance_setting.dart';
import 'shared_prefs_base.dart';

class AppearanceStorage extends SharedPreferencesBase<AppearanceSetting> {
  static const String _prefix = 'appearance';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<AppearanceSetting> themeNotifier =
      ValueNotifier(AppearanceSetting.defaults(themeMode: ThemeMode.system));

  AppearanceStorage(super.prefs) {
    _loadInitialTheme();
    changes.listen((_) {
      final items = getItems();
      themeNotifier.value = items.isNotEmpty
          ? items.first
          : AppearanceSetting.defaults(themeMode: ThemeMode.system);
    });
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static AppearanceStorage? _instance;

  static Future<AppearanceStorage> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = AppearanceStorage(prefs);
    return _instance!;
  }

  static AppearanceStorage get instance {
    if (_instance == null) {
      throw Exception('AppearanceStorage not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(AppearanceSetting item) => 'settings';

  @override
  Map<String, dynamic> serializeToFields(AppearanceSetting item) {
    return {
      'themeMode': item.themeMode.index,
      'selection': item.selection.index,
      'colors': item.colors.toJson(),
      'font': item.font.toJson(),
      'superDarkMode': item.superDarkMode,
      'dynamicColor': item.dynamicColor,
      'enableAnimation': item.enableAnimation,
    };
  }

  @override
  AppearanceSetting deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    final themeModeIndex = fields['themeMode'] as int?;
    final selectionIndex = fields['selection'] as int?;

    final mode = (themeModeIndex != null &&
            themeModeIndex >= 0 &&
            themeModeIndex < ThemeMode.values.length)
        ? ThemeMode.values[themeModeIndex]
        : ThemeMode.system;

    final selection = (selectionIndex != null &&
            selectionIndex >= 0 &&
            selectionIndex < ThemeSelection.values.length)
        ? ThemeSelection.values[selectionIndex]
        : ThemeSelection.system;

    final isDark = mode == ThemeMode.dark;
    final colorsMap = fields['colors'] as Map<String, dynamic>?;
    final fontMap = fields['font'] as Map<String, dynamic>?;

    return AppearanceSetting(
      themeMode: mode,
      selection: selection,
      colors: colorsMap != null
          ? ColorSettings.fromJson(colorsMap)
          : ColorSettings.defaults(isDark: isDark),
      font: fontMap != null
          ? FontSettings.fromJson(fontMap)
          : FontSettings.defaults(),
      superDarkMode: fields['superDarkMode'] as bool? ?? false,
      dynamicColor: fields['dynamicColor'] as bool? ?? false,
      enableAnimation: fields['enableAnimation'] as bool? ?? true,
    );
  }

  Future<void> updateSettings(AppearanceSetting settings) async {
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  AppearanceSetting get currentTheme => themeNotifier.value;
}
