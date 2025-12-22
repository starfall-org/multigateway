import 'dart:convert';
import 'package:flutter/material.dart';

//// Theme selection high-level mode for UI:
/// - system, light, dark mirror ThemeMode
/// - custom enables custom primary/secondary color presets & pickers
enum ThemeSelection { system, light, dark, custom }

/// Secondary background behavior for surfaces like dialogs/drawers/sidebars
/// - off: same as main background; add high-contrast border
/// - auto: slight delta from main background for subtle separation
/// - on: tinted from secondary color for stronger separation
enum SecondaryBackgroundMode { off, auto, on }

class AppearanceSetting {
  final ThemeMode themeMode; // actual brightness control used by MaterialApp
  final ThemeSelection selection; // UI selection: system/light/dark/custom
  final int primaryColor; // ARGB int value
  final int secondaryColor; // ARGB int value
  final int backgroundColor; // ARGB int value
  final int surfaceColor; // ARGB int value
  final int textColor; // ARGB int value
  final int darkmodeTextColor; // ARGB int value
  final int textHintColor; // ARGB int value
  final int darkmodeTextHintColor; // ARGB int value
  final bool superDarkMode; // true => use pure black background for dark theme
  final bool
  dynamicColor; // true => use dynamic color (Material You) if supported
  final String fontFamily;
  final int chatFontSize;
  final int appFontSize;
  final bool enableAnimation;
  final SecondaryBackgroundMode secondaryBackgroundMode;

  const AppearanceSetting({
    required this.themeMode,
    required this.selection,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.darkmodeTextColor,
    required this.textHintColor,
    required this.darkmodeTextHintColor,
    required this.superDarkMode,
    required this.dynamicColor,
    required this.fontFamily,
    required this.chatFontSize,
    required this.appFontSize,
    required this.enableAnimation,
    required this.secondaryBackgroundMode,
  });

  factory AppearanceSetting.defaults() {
    return AppearanceSetting(
      themeMode: ThemeMode.system,
      selection: ThemeSelection.system,
      primaryColor: Colors.blue.toARGB32(),
      secondaryColor: Colors.purple.toARGB32(),
      backgroundColor: Colors.white.toARGB32(),
      surfaceColor: Colors.white70.toARGB32(),
      textColor: Colors.black.toARGB32(),
      darkmodeTextColor: Colors.white.toARGB32(),
      textHintColor: Colors.black.toARGB32(),
      darkmodeTextHintColor: Colors.white.toARGB32(),
      superDarkMode: false,
      dynamicColor: false,
      fontFamily: 'Roboto',
      chatFontSize: 16,
      appFontSize: 16,
      enableAnimation: true,
      secondaryBackgroundMode: SecondaryBackgroundMode.off,
    );
  }

  AppearanceSetting copyWith({
    ThemeMode? themeMode,
    ThemeSelection? selection,
    int? primaryColor,
    int? secondaryColor,
    int? backgroundColor,
    int? surfaceColor,
    int? textColor,
    int? darkmodeTextColor,
    int? textHintColor,
    int? darkmodeTextHintColor,
    bool? superDarkMode,
    bool? dynamicColor,
    String? fontFamily,
    int? chatFontSize,
    int? appFontSize,
    bool? enableAnimation,
    SecondaryBackgroundMode? secondaryBackgroundMode,
  }) {
    return AppearanceSetting(
      themeMode: themeMode ?? this.themeMode,
      selection: selection ?? this.selection,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      darkmodeTextColor: darkmodeTextColor ?? this.darkmodeTextColor,
      textHintColor: textHintColor ?? this.textHintColor,
      darkmodeTextHintColor:
          darkmodeTextHintColor ?? this.darkmodeTextHintColor,
      superDarkMode: superDarkMode ?? this.superDarkMode,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      fontFamily: fontFamily ?? this.fontFamily,
      chatFontSize: chatFontSize ?? this.chatFontSize,
      appFontSize: appFontSize ?? this.appFontSize,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      secondaryBackgroundMode:
          secondaryBackgroundMode ?? this.secondaryBackgroundMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'selection': selection.index,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'textColor': textColor,
      'darkmodeTextColor': darkmodeTextColor,
      'textHintColor': textHintColor,
      'darkmodeTextHintColor': darkmodeTextHintColor,
      'superDarkMode': superDarkMode,
      'dynamicColor': dynamicColor,
      'fontFamily': fontFamily,
      'chatFontSize': chatFontSize,
      'appFontSize': appFontSize,
      'enableAnimation': enableAnimation,
      'secondaryBackgroundMode': secondaryBackgroundMode.index,
    };
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) {
    try {
      final int? themeModeIndex = json['themeMode'] as int?;
      final int? selectionIndex = json['selection'] as int?;
      final int? primary = json['primaryColor'] as int?;
      final int? secondary = json['secondaryColor'] as int?;
      final int? backgroundColor = json['backgroundColor'] as int?;
      final int? surfaceColor = json['surfaceColor'] as int?;
      final int? textColor = json['textColor'] as int?;
      final int? darkmodeTextColor = json['darkmodeTextColor'] as int?;
      final int? textHintColor = json['textHintColor'] as int?;
      final int? darkmodeTextHintColor = json['darkmodeTextHintColor'] as int?;
      final bool superDarkMode = (json['superDarkMode'] as bool?) ?? false;
      final bool dynamicColor = (json['dynamicColor'] as bool?) ?? false;
      final String? fontFamily = json['fontFamily'] as String?;
      final int? chatFontSize = json['chatFontSize'] as int?;
      final int? appFontSize = json['appFontSize'] as int?;
      final int? oldFontSize = json['fontSize'] as int?;
      final bool enableAnimation = (json['enableAnimation'] as bool?) ?? false;
      final int? secondaryBgIndex = json['secondaryBackgroundMode'] as int?;

      // Backward compatibility with older schema using 'colorValue'
      final int? oldColor = json['colorValue'] as int?;

      final ThemeMode mode =
          (themeModeIndex != null &&
              themeModeIndex >= 0 &&
              themeModeIndex < ThemeMode.values.length)
          ? ThemeMode.values[themeModeIndex]
          : ThemeMode.system;

      final ThemeSelection sel =
          (selectionIndex != null &&
              selectionIndex >= 0 &&
              selectionIndex < ThemeSelection.values.length)
          ? ThemeSelection.values[selectionIndex]
          : ThemeSelection.system;

      final SecondaryBackgroundMode secBg =
          (secondaryBgIndex != null &&
              secondaryBgIndex >= 0 &&
              secondaryBgIndex < SecondaryBackgroundMode.values.length)
          ? SecondaryBackgroundMode.values[secondaryBgIndex]
          : SecondaryBackgroundMode.off;

      return AppearanceSetting(
        themeMode: mode,
        selection: sel,
        primaryColor: primary ?? oldColor ?? Colors.blue.toARGB32(),
        secondaryColor: secondary ?? Colors.purple.toARGB32(),
        backgroundColor: backgroundColor ?? Colors.white.toARGB32(),
        surfaceColor: surfaceColor ?? Colors.white.toARGB32(),
        textColor: textColor ?? Colors.black.toARGB32(),
        darkmodeTextColor: darkmodeTextColor ?? Colors.white.toARGB32(),
        textHintColor: textHintColor ?? Colors.black.toARGB32(),
        darkmodeTextHintColor: darkmodeTextHintColor ?? Colors.white.toARGB32(),
        superDarkMode: superDarkMode,
        dynamicColor: dynamicColor,
        fontFamily: fontFamily ?? 'Roboto',
        chatFontSize: chatFontSize ?? oldFontSize ?? 16,
        appFontSize: appFontSize ?? oldFontSize ?? 16,
        enableAnimation: enableAnimation,
        secondaryBackgroundMode: secBg,
      );
    } catch (_) {
      return AppearanceSetting.defaults();
    }
  }

  String toJsonString() => json.encode(toJson());

  factory AppearanceSetting.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) return AppearanceSetting.defaults();
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return AppearanceSetting.fromJson(data);
      }
      return AppearanceSetting.defaults();
    } catch (_) {
      return AppearanceSetting.defaults();
    }
  }
}
