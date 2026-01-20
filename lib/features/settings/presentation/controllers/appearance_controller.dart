import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/storage/appearance_storage.dart';
import 'package:signals/signals_flutter.dart';

enum ColorType { primary, secondary, background, surface, text, textHint }

class AppearanceController {
  late final AppearanceStorage _repository;
  final settings = signal<AppearanceSetting>(
    AppearanceSetting.defaults(themeMode: ThemeMode.system),
  );
  final isInitialized = signal<bool>(false);
  Future<void>? _initializationFuture;

  /// Future để theo dõi quá trình khởi tạo
  Future<void> get initializationFuture =>
      _initializationFuture ??= _initialize();

  AppearanceController() {
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      _repository = await AppearanceStorage.instance;
      settings.value = _repository.theme.value;
      isInitialized.value = true;
    } catch (e) {
      settings.value = AppearanceSetting.defaults(themeMode: ThemeMode.system);
      isInitialized.value = true;
      if (kDebugMode) {
        debugPrint('AppearanceController initialization error: $e');
      }
    }
  }

  Future<void> updateSelection(ThemeSelection selection) async {
    if (!isInitialized.value) await _initialize();
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = settings.value.themeMode;
    bool shouldResetColors = false;

    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        shouldResetColors =
            settings.value.selection != ThemeSelection.system &&
            settings.value.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        shouldResetColors =
            settings.value.selection != ThemeSelection.light &&
            settings.value.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        shouldResetColors =
            settings.value.selection != ThemeSelection.dark &&
            settings.value.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.custom:
        // keep current themeMode; custom only affects colors
        mode = settings.value.themeMode;
        break;
    }

    AppearanceSetting newSettings;
    if (shouldResetColors) {
      // Reset màu sắc về mặc định cho theme mode mới
      final defaultSettings = AppearanceSetting.defaults(themeMode: mode);
      newSettings = settings.value.copyWith(
        selection: selection,
        themeMode: mode,
        colors: defaultSettings.colors,
      );
    } else {
      newSettings = settings.value.copyWith(
        selection: selection,
        themeMode: mode,
      );
    }

    await _updateSettings(newSettings);
  }

  Future<void> updateColor(ColorType type, int colorValue) async {
    final newColors = switch (type) {
      ColorType.primary => settings.value.colors.copyWith(
        primaryColor: colorValue,
      ),
      ColorType.secondary => settings.value.colors.copyWith(
        secondaryColor: colorValue,
      ),
      ColorType.background => settings.value.colors.copyWith(
        backgroundColor: colorValue,
      ),
      ColorType.surface => settings.value.colors.copyWith(
        surfaceColor: colorValue,
      ),
      ColorType.text => settings.value.colors.copyWith(textColor: colorValue),
      ColorType.textHint => settings.value.colors.copyWith(
        textHintColor: colorValue,
      ),
    };
    final newSettings = settings.value.copyWith(colors: newColors);
    await _updateSettings(newSettings);
  }

  int getColor(ColorType type) {
    return switch (type) {
      ColorType.primary => settings.value.colors.primaryColor,
      ColorType.secondary => settings.value.colors.secondaryColor,
      ColorType.background => settings.value.colors.backgroundColor,
      ColorType.surface => settings.value.colors.surfaceColor,
      ColorType.text => settings.value.colors.textColor,
      ColorType.textHint => settings.value.colors.textHintColor,
    };
  }

  Future<void> togglePureDark(bool value) async {
    final newSettings = settings.value.copyWith(superDarkMode: value);
    await _updateSettings(newSettings);
  }

  Future<void> toggleMaterialYou(bool value) async {
    final newSettings = settings.value.copyWith(dynamicColor: value);
    await _updateSettings(newSettings);
  }

  Future<void> updateColorSchemePreset(ColorSchemePreset preset) async {
    // Nếu không phải custom, cập nhật màu sắc từ preset
    if (preset != ColorSchemePreset.custom) {
      final isDark =
          settings.value.themeMode == ThemeMode.dark ||
          (settings.value.themeMode == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                  Brightness.dark);

      final newColors = ColorSettings.fromPreset(
        preset: preset,
        isDark: isDark,
      );

      final newSettings = settings.value.copyWith(
        colorSchemePreset: preset,
        colors: newColors,
      );
      await _updateSettings(newSettings);
    } else {
      // Chỉ cập nhật preset, giữ nguyên màu hiện tại
      final newSettings = settings.value.copyWith(colorSchemePreset: preset);
      await _updateSettings(newSettings);
    }
  }

  @Deprecated('removed')
  Future<void> updateSecondaryBackgroundMode(
    SecondaryBackgroundMode mode,
  ) async {}

  Future<void> _updateSettings(AppearanceSetting newSettings) async {
    await _repository.updateSettings(newSettings);
    settings.value = newSettings;
  }

  void dispose() {
    settings.dispose();
    isInitialized.dispose();
  }
}
