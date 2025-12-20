import 'package:flutter/material.dart';
import '../../../core/models/appearances.dart';
import '../../../core/storage/appearances_repository.dart';

enum ColorType {
  primary,
  secondary,
  background,
  surface,
  text,
  darkmodeText,
  textHint,
  darkmodeTextHint,
}

class AppearanceViewModel extends ChangeNotifier {
  final AppearancesRepository _repository;
  Appearances settings;

  AppearanceViewModel()
      : _repository = AppearancesRepository.instance,
        settings = AppearancesRepository.instance.currentTheme;

  Future<void> updateSelection(ThemeSelection selection) async {
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = settings.themeMode;
    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        break;
      case ThemeSelection.custom:
        // keep current themeMode; custom only affects colors
        mode = settings.themeMode;
        break;
    }
    final newSettings = settings.copyWith(
      selection: selection,
      themeMode: mode,
    );
    await _updateSettings(newSettings);
  }

  Future<void> updateColor(ColorType type, int colorValue) async {
    Appearances newSettings;
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
      case ColorType.darkmodeText:
        newSettings = settings.copyWith(darkmodeTextColor: colorValue);
        break;
      case ColorType.textHint:
        newSettings = settings.copyWith(textHintColor: colorValue);
        break;
      case ColorType.darkmodeTextHint:
        newSettings = settings.copyWith(darkmodeTextHintColor: colorValue);
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
      case ColorType.darkmodeText:
        return settings.darkmodeTextColor;
      case ColorType.textHint:
        return settings.textHintColor;
      case ColorType.darkmodeTextHint:
        return settings.darkmodeTextHintColor;
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

  Future<void> _updateSettings(Appearances newSettings) async {
    await _repository.updateSettings(newSettings);
    settings = newSettings;
    notifyListeners();
  }
}