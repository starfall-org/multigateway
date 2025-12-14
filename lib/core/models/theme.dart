import 'dart:convert';
import 'package:flutter/material.dart';

class ThemeSettings {
  final ThemeMode themeMode;
  final int colorValue;

  ThemeSettings({required this.themeMode, required this.colorValue});

  factory ThemeSettings.defaults() {
    return ThemeSettings(
      themeMode: ThemeMode.system,
      colorValue: Colors.blue.toARGB32(),
    );
  }

  ThemeSettings copyWith({ThemeMode? themeMode, int? colorValue}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.index, 'colorValue': colorValue};
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int],
      colorValue: json['colorValue'] as int,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory ThemeSettings.fromJsonString(String jsonString) =>
      ThemeSettings.fromJson(json.decode(jsonString));
}