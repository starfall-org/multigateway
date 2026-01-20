import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appearance_setting.g.dart';

enum ThemeSelection { system, light, dark, custom }

enum SecondaryBackgroundMode { off, auto, on }

enum ColorSchemePreset {
  blue,
  purple,
  green,
  orange,
  pink,
  red,
  teal,
  indigo,
  custom,
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class ColorSettings {
  final int primaryColor;
  final int secondaryColor;
  final int backgroundColor;
  final int surfaceColor;
  final int textColor;
  final int textHintColor;

  ColorSettings({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textHintColor,
  });

  factory ColorSettings.defaults({required bool isDark}) {
    return ColorSettings(
      primaryColor: Colors.blue.toARGB32(),
      secondaryColor: Colors.purple.toARGB32(),
      backgroundColor: isDark
          ? const Color(0xFF121212).toARGB32()
          : Colors.white.toARGB32(),
      surfaceColor: isDark
          ? const Color(0xFF121212).toARGB32()
          : Colors.white.toARGB32(),
      textColor: isDark
          ? const Color(0xFFE6E6E6).toARGB32()
          : const Color(0xFF1C1B1F).toARGB32(),
      textHintColor: isDark
          ? const Color(0xFFB3B3B3).toARGB32()
          : const Color(0xFF49454F).toARGB32(),
    );
  }

  factory ColorSettings.fromPreset({
    required ColorSchemePreset preset,
    required bool isDark,
  }) {
    final Color primary;
    final Color secondary;

    switch (preset) {
      case ColorSchemePreset.blue:
        primary = Colors.blue;
        secondary = Colors.lightBlue;
        break;
      case ColorSchemePreset.purple:
        primary = Colors.purple;
        secondary = Colors.deepPurple;
        break;
      case ColorSchemePreset.green:
        primary = Colors.green;
        secondary = Colors.lightGreen;
        break;
      case ColorSchemePreset.orange:
        primary = Colors.orange;
        secondary = Colors.deepOrange;
        break;
      case ColorSchemePreset.pink:
        primary = Colors.pink;
        secondary = Colors.pinkAccent;
        break;
      case ColorSchemePreset.red:
        primary = Colors.red;
        secondary = Colors.redAccent;
        break;
      case ColorSchemePreset.teal:
        primary = Colors.teal;
        secondary = Colors.cyan;
        break;
      case ColorSchemePreset.indigo:
        primary = Colors.indigo;
        secondary = Colors.indigoAccent;
        break;
      case ColorSchemePreset.custom:
        return ColorSettings.defaults(isDark: isDark);
    }

    return ColorSettings(
      primaryColor: primary.toARGB32(),
      secondaryColor: secondary.toARGB32(),
      backgroundColor: isDark
          ? const Color(0xFF121212).toARGB32()
          : Colors.white.toARGB32(),
      surfaceColor: isDark
          ? const Color(0xFF121212).toARGB32()
          : Colors.white.toARGB32(),
      textColor: isDark
          ? const Color(0xFFE6E6E6).toARGB32()
          : const Color(0xFF1C1B1F).toARGB32(),
      textHintColor: isDark
          ? const Color(0xFFB3B3B3).toARGB32()
          : const Color(0xFF49454F).toARGB32(),
    );
  }

  ColorSettings copyWith({
    int? primaryColor,
    int? secondaryColor,
    int? backgroundColor,
    int? surfaceColor,
    int? textColor,
    int? textHintColor,
  }) {
    return ColorSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      textHintColor: textHintColor ?? this.textHintColor,
    );
  }

  factory ColorSettings.fromJson(Map<String, dynamic> json) =>
      _$ColorSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ColorSettingsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class FontSettings {
  final String fontFamily;
  final int chatFontSize;
  final int appFontSize;

  FontSettings({
    required this.fontFamily,
    required this.chatFontSize,
    required this.appFontSize,
  });

  factory FontSettings.defaults() {
    return FontSettings(
      fontFamily: 'Roboto',
      chatFontSize: 16,
      appFontSize: 16,
    );
  }

  FontSettings copyWith({
    String? fontFamily,
    int? chatFontSize,
    int? appFontSize,
  }) {
    return FontSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      chatFontSize: chatFontSize ?? this.chatFontSize,
      appFontSize: appFontSize ?? this.appFontSize,
    );
  }

  factory FontSettings.fromJson(Map<String, dynamic> json) =>
      _$FontSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$FontSettingsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AppearanceSetting {
  final ThemeMode themeMode;
  final ThemeSelection selection;
  final ColorSettings colors;
  final FontSettings font;
  final bool superDarkMode;
  final bool dynamicColor;
  final ColorSchemePreset colorSchemePreset;
  final bool enableAnimation;

  AppearanceSetting({
    this.themeMode = ThemeMode.system,
    required this.selection,
    required this.colors,
    required this.font,
    required this.superDarkMode,
    required this.dynamicColor,
    this.colorSchemePreset = ColorSchemePreset.blue,
    required this.enableAnimation,
  });

  factory AppearanceSetting.defaults({ThemeMode? themeMode}) {
    final bool isDark = themeMode == ThemeMode.dark;

    return AppearanceSetting(
      themeMode: themeMode ?? ThemeMode.system,
      selection: ThemeSelection.system,
      colors: ColorSettings.defaults(isDark: isDark),
      font: FontSettings.defaults(),
      superDarkMode: false,
      dynamicColor: true,
      colorSchemePreset: ColorSchemePreset.blue,
      enableAnimation: true,
    );
  }

  AppearanceSetting copyWith({
    ThemeMode? themeMode,
    ThemeSelection? selection,
    ColorSettings? colors,
    FontSettings? font,
    bool? superDarkMode,
    bool? dynamicColor,
    ColorSchemePreset? colorSchemePreset,
    bool? enableAnimation,
  }) {
    return AppearanceSetting(
      themeMode: themeMode ?? this.themeMode,
      selection: selection ?? this.selection,
      colors: colors ?? this.colors,
      font: font ?? this.font,
      superDarkMode: superDarkMode ?? this.superDarkMode,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      colorSchemePreset: colorSchemePreset ?? this.colorSchemePreset,
      enableAnimation: enableAnimation ?? this.enableAnimation,
    );
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingFromJson(json);

  Map<String, dynamic> toJson() => _$AppearanceSettingToJson(this);

  String toJsonString() => json.encode(toJson());

  factory AppearanceSetting.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) {
        return AppearanceSetting.defaults(themeMode: ThemeMode.system);
      }
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return AppearanceSetting.fromJson(data);
      }
      return AppearanceSetting.defaults(themeMode: ThemeMode.system);
    } catch (_) {
      return AppearanceSetting.defaults(themeMode: ThemeMode.system);
    }
  }
}
