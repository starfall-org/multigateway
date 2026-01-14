import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/storage/appearance_storage.dart';

enum ColorType { primary, secondary, background, surface, text, textHint }

class AppearanceController extends ChangeNotifier {
  late final AppearanceStorage _repository;
  late AppearanceSetting settings;
  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  /// Getter để kiểm tra trạng thái khởi tạo
  bool get isInitialized => _isInitialized;

  /// Future để theo dõi quá trình khởi tạo
  Future<void> get initializationFuture =>
      _initializationFuture ??= _initialize();

  AppearanceController() {
    // Initialize with default settings immediately
    settings = AppearanceSetting.defaults(themeMode: ThemeMode.system);
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      _repository = await AppearanceStorage.instance;
      settings = _repository.currentTheme;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Fallback to default settings if initialization fails
      settings = AppearanceSetting.defaults(themeMode: ThemeMode.system);
      _isInitialized = true;
      notifyListeners();
      if (kDebugMode) {
        print('AppearanceController initialization error: $e');
      }
    }
  }

  Future<void> updateSelection(ThemeSelection selection) async {
    if (!_isInitialized) await _initialize();
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = settings.themeMode;
    bool shouldResetColors = false;

    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        shouldResetColors =
            settings.selection != ThemeSelection.system &&
            settings.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        shouldResetColors =
            settings.selection != ThemeSelection.light &&
            settings.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        shouldResetColors =
            settings.selection != ThemeSelection.dark &&
            settings.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.custom:
        // keep current themeMode; custom only affects colors
        mode = settings.themeMode;
        break;
    }

    AppearanceSetting newSettings;
    if (shouldResetColors) {
      // Reset màu sắc về mặc định cho theme mode mới
      final defaultSettings = AppearanceSetting.defaults(themeMode: mode);
      newSettings = settings.copyWith(
        selection: selection,
        themeMode: mode,
        colors: defaultSettings.colors,
      );
    } else {
      newSettings = settings.copyWith(selection: selection, themeMode: mode);
    }

    await _updateSettings(newSettings);
  }

  Future<void> updateColor(ColorType type, int colorValue) async {
    final newColors = switch (type) {
      ColorType.primary => settings.colors.copyWith(primaryColor: colorValue),
      ColorType.secondary => settings.colors.copyWith(
        secondaryColor: colorValue,
      ),
      ColorType.background => settings.colors.copyWith(
        backgroundColor: colorValue,
      ),
      ColorType.surface => settings.colors.copyWith(surfaceColor: colorValue),
      ColorType.text => settings.colors.copyWith(textColor: colorValue),
      ColorType.textHint => settings.colors.copyWith(textHintColor: colorValue),
    };
    final newSettings = settings.copyWith(colors: newColors);
    await _updateSettings(newSettings);
  }

  int getColor(ColorType type) {
    return switch (type) {
      ColorType.primary => settings.colors.primaryColor,
      ColorType.secondary => settings.colors.secondaryColor,
      ColorType.background => settings.colors.backgroundColor,
      ColorType.surface => settings.colors.surfaceColor,
      ColorType.text => settings.colors.textColor,
      ColorType.textHint => settings.colors.textHintColor,
    };
  }

  Future<void> togglePureDark(bool value) async {
    final newSettings = settings.copyWith(superDarkMode: value);
    await _updateSettings(newSettings);
  }

  Future<void> toggleMaterialYou(bool value) async {
    final newSettings = settings.copyWith(dynamicColor: value);
    await _updateSettings(newSettings);
  }

  Future<void> updateColorSchemePreset(ColorSchemePreset preset) async {
    // Nếu không phải custom, cập nhật màu sắc từ preset
    if (preset != ColorSchemePreset.custom) {
      final isDark =
          settings.themeMode == ThemeMode.dark ||
          (settings.themeMode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);

      final newColors = ColorSettings.fromPreset(
        preset: preset,
        isDark: isDark,
      );

      final newSettings = settings.copyWith(
        colorSchemePreset: preset,
        colors: newColors,
      );
      await _updateSettings(newSettings);
    } else {
      // Chỉ cập nhật preset, giữ nguyên màu hiện tại
      final newSettings = settings.copyWith(colorSchemePreset: preset);
      await _updateSettings(newSettings);
    }
  }

  @Deprecated('removed')
  Future<void> updateSecondaryBackgroundMode(
    SecondaryBackgroundMode mode,
  ) async {}

  Future<void> _updateSettings(AppearanceSetting newSettings) async {
    await _repository.updateSettings(newSettings);
    settings = newSettings;
    notifyListeners();
  }
}
