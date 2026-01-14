// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appearance_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorSettings _$ColorSettingsFromJson(Map<String, dynamic> json) =>
    ColorSettings(
      primaryColor: (json['primary_color'] as num).toInt(),
      secondaryColor: (json['secondary_color'] as num).toInt(),
      backgroundColor: (json['background_color'] as num).toInt(),
      surfaceColor: (json['surface_color'] as num).toInt(),
      textColor: (json['text_color'] as num).toInt(),
      textHintColor: (json['text_hint_color'] as num).toInt(),
    );

Map<String, dynamic> _$ColorSettingsToJson(ColorSettings instance) =>
    <String, dynamic>{
      'primary_color': instance.primaryColor,
      'secondary_color': instance.secondaryColor,
      'background_color': instance.backgroundColor,
      'surface_color': instance.surfaceColor,
      'text_color': instance.textColor,
      'text_hint_color': instance.textHintColor,
    };

FontSettings _$FontSettingsFromJson(Map<String, dynamic> json) => FontSettings(
      fontFamily: json['font_family'] as String,
      chatFontSize: (json['chat_font_size'] as num).toInt(),
      appFontSize: (json['app_font_size'] as num).toInt(),
    );

Map<String, dynamic> _$FontSettingsToJson(FontSettings instance) =>
    <String, dynamic>{
      'font_family': instance.fontFamily,
      'chat_font_size': instance.chatFontSize,
      'app_font_size': instance.appFontSize,
    };

AppearanceSetting _$AppearanceSettingFromJson(Map<String, dynamic> json) =>
    AppearanceSetting(
      themeMode: $enumDecodeNullable(_$ThemeModeEnumMap, json['theme_mode']) ??
          ThemeMode.system,
      selection: $enumDecode(_$ThemeSelectionEnumMap, json['selection']),
      colors: ColorSettings.fromJson(json['colors'] as Map<String, dynamic>),
      font: FontSettings.fromJson(json['font'] as Map<String, dynamic>),
      superDarkMode: json['super_dark_mode'] as bool,
      dynamicColor: json['dynamic_color'] as bool,
      colorSchemePreset: $enumDecodeNullable(
              _$ColorSchemePresetEnumMap, json['color_scheme_preset']) ??
          ColorSchemePreset.blue,
      enableAnimation: json['enable_animation'] as bool,
    );

Map<String, dynamic> _$AppearanceSettingToJson(AppearanceSetting instance) =>
    <String, dynamic>{
      'theme_mode': _$ThemeModeEnumMap[instance.themeMode]!,
      'selection': _$ThemeSelectionEnumMap[instance.selection]!,
      'colors': instance.colors.toJson(),
      'font': instance.font.toJson(),
      'super_dark_mode': instance.superDarkMode,
      'dynamic_color': instance.dynamicColor,
      'color_scheme_preset':
          _$ColorSchemePresetEnumMap[instance.colorSchemePreset]!,
      'enable_animation': instance.enableAnimation,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ThemeSelectionEnumMap = {
  ThemeSelection.system: 'system',
  ThemeSelection.light: 'light',
  ThemeSelection.dark: 'dark',
  ThemeSelection.custom: 'custom',
};

const _$ColorSchemePresetEnumMap = {
  ColorSchemePreset.blue: 'blue',
  ColorSchemePreset.purple: 'purple',
  ColorSchemePreset.green: 'green',
  ColorSchemePreset.orange: 'orange',
  ColorSchemePreset.pink: 'pink',
  ColorSchemePreset.red: 'red',
  ColorSchemePreset.teal: 'teal',
  ColorSchemePreset.indigo: 'indigo',
  ColorSchemePreset.custom: 'custom',
};
