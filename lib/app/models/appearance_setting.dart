import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'appearance_setting.g.dart';

enum ThemeSelection { system, light, dark, custom }

enum SecondaryBackgroundMode { off, auto, on }

@JsonSerializable(fieldRename: FieldRename.snake)
class AppearanceSetting {
  final ThemeMode themeMode;
  final ThemeSelection selection;
  final int primaryColor;
  final int secondaryColor;
  final int backgroundColor;
  final int surfaceColor;
  final int textColor;
  final int textHintColor;
  final bool superDarkMode;
  final bool dynamicColor;
  final String fontFamily;
  final int chatFontSize;
  final int appFontSize;
  final bool enableAnimation;

  AppearanceSetting({
    this.themeMode = ThemeMode.system,
    required this.selection,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textHintColor,
    required this.superDarkMode,
    required this.dynamicColor,
    required this.fontFamily,
    required this.chatFontSize,
    required this.appFontSize,
    required this.enableAnimation,
  });

  factory AppearanceSetting.defaults({ThemeMode? themeMode}) {
    final bool isDark = themeMode == ThemeMode.dark;

    return AppearanceSetting(
      themeMode: themeMode ?? ThemeMode.system,
      selection: ThemeSelection.system,
      primaryColor: Colors.blue.toARGB32(),
      secondaryColor: Colors.purple.toARGB32(),
      backgroundColor: isDark ? Colors.black.toARGB32() : Colors.white.toARGB32(),
      surfaceColor: isDark ? Colors.black.toARGB32() : Colors.white.toARGB32(),
      textColor: isDark ? Colors.white.toARGB32() : Colors.black.toARGB32(),
      textHintColor: isDark ? Colors.white.toARGB32() : Colors.black.toARGB32(),
      superDarkMode: false,
      dynamicColor: false,
      fontFamily: 'Roboto',
      chatFontSize: 16,
      appFontSize: 16,
      enableAnimation: true,
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
    int? textHintColor,
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
      textHintColor: textHintColor ?? this.textHintColor,
      superDarkMode: superDarkMode ?? this.superDarkMode,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      fontFamily: fontFamily ?? this.fontFamily,
      chatFontSize: chatFontSize ?? this.chatFontSize,
      appFontSize: appFontSize ?? this.appFontSize,
      enableAnimation: enableAnimation ?? this.enableAnimation,
    );
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) =>
      _$AppearanceSettingFromJson(json);

  Map<String, dynamic> toJson() => _$AppearanceSettingToJson(this);

  String toJsonString() => json.encode(toJson());

  factory AppearanceSetting.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) return AppearanceSetting.defaults(themeMode: ThemeMode.system);
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
