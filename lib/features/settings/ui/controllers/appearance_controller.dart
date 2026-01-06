import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/storage/appearance.dart';

enum ColorType {
  primary,
  secondary,
  background,
  surface,
  text,
  textHint,
}

class AppearanceViewModel extends ChangeNotifier {
  final AppearanceStorage _repository;
  AppearanceSetting settings;

  AppearanceViewModel()
    : _repository = AppearanceStorage.instance,
      settings = AppearanceStorage.instance.currentTheme;

  Future<void> updateSelection(ThemeSelection selection) async {
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = settings.themeMode;
    bool shouldResetColors = false;
    
    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        shouldResetColors = settings.selection != ThemeSelection.system && settings.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        shouldResetColors = settings.selection != ThemeSelection.light && settings.selection != ThemeSelection.custom;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        shouldResetColors = settings.selection != ThemeSelection.dark && settings.selection != ThemeSelection.custom;
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
        primaryColor: defaultSettings.primaryColor,
        secondaryColor: defaultSettings.secondaryColor,
        backgroundColor: defaultSettings.backgroundColor,
        surfaceColor: defaultSettings.surfaceColor,
        textColor: defaultSettings.textColor,
        textHintColor: defaultSettings.textHintColor,
      );
    } else {
      newSettings = settings.copyWith(
        selection: selection,
        themeMode: mode,
      );
    }
    
    await _updateSettings(newSettings);
  }

  Future<void> updateColor(ColorType type, int colorValue) async {
    AppearanceSetting newSettings;
    switch (type) {
      case ColorType.primary:
        newSettings = settings.copyWith(primaryColor: colorValue);
        break;
      case ColorType.secondary:
        newSettings = settings.copyWith(secondaryColor: colorValue);
        break;
      case ColorType.background:
        newSettings = settings.copyWith(backgroundColor: colorValue);
        break;
      case ColorType.surface:
        newSettings = settings.copyWith(surfaceColor: colorValue);
        break;
      case ColorType.text:
        newSettings = settings.copyWith(textColor: colorValue);
        break;
      case ColorType.textHint:
        newSettings = settings.copyWith(textHintColor: colorValue);
        break;
    }
    await _updateSettings(newSettings);
  }

  int getColor(ColorType type) {
    switch (type) {
      case ColorType.primary:
        return settings.primaryColor;
      case ColorType.secondary:
        return settings.secondaryColor;
      case ColorType.background:
        return settings.backgroundColor;
      case ColorType.surface:
        return settings.surfaceColor;
      case ColorType.text:
        return settings.textColor;
      case ColorType.textHint:
        return settings.textHintColor;
    }
  }

  Future<void> togglePureDark(bool value) async {
    final newSettings = settings.copyWith(superDarkMode: value);
    await _updateSettings(newSettings);
  }

  Future<void> toggleMaterialYou(bool value) async {
    final newSettings = settings.copyWith(dynamicColor: value);
    await _updateSettings(newSettings);
  }

  Future<void> updateSecondaryBackgroundMode(
    SecondaryBackgroundMode mode,
  ) async {
    final newSettings = settings.copyWith(secondaryBackgroundMode: mode);
    await _updateSettings(newSettings);
  }

  Future<void> _updateSettings(AppearanceSetting newSettings) async {
    await _repository.updateSettings(newSettings);
    settings = newSettings;
    notifyListeners();
  }
}

