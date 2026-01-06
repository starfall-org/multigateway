import 'dart:convert';
import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'preferences_setting.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class PreferencesSetting {
  final bool persistChatSelection;
  final VibrationSettings vibrationSettings;
  final bool hideStatusBar;
  final bool hideNavigationBar;
  final bool debugMode;
  final bool hasInitializedIcons;
  final LanguageSetting languageSetting;

  const PreferencesSetting({
    required this.persistChatSelection,
    required this.vibrationSettings,
    required this.languageSetting,
    this.hideStatusBar = false,
    this.hideNavigationBar = false,
    this.debugMode = false,
    this.hasInitializedIcons = false,
  });

  factory PreferencesSetting.defaults() {
    return PreferencesSetting(
      persistChatSelection: false,
      vibrationSettings: VibrationSettings.defaults(),
      languageSetting: LanguageSetting.defaults(),
      hideStatusBar: false,
      hideNavigationBar: false,
      debugMode: false,
      hasInitializedIcons: false,
    );
  }

  PreferencesSetting copyWith({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    LanguageSetting? languageSetting,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
    bool? hasInitializedIcons,
  }) {
    return PreferencesSetting(
      persistChatSelection: persistChatSelection ?? this.persistChatSelection,
      vibrationSettings: vibrationSettings ?? this.vibrationSettings,
      languageSetting: languageSetting ?? this.languageSetting,
      hideStatusBar: hideStatusBar ?? this.hideStatusBar,
      hideNavigationBar: hideNavigationBar ?? this.hideNavigationBar,
      debugMode: debugMode ?? this.debugMode,
      hasInitializedIcons: hasInitializedIcons ?? this.hasInitializedIcons,
    );
  }

  factory PreferencesSetting.fromJson(Map<String, dynamic> json) =>
      _$PreferencesSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesSettingToJson(this);

  String toJsonString() => json.encode(toJson());

  factory PreferencesSetting.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) {
        return PreferencesSetting.defaults();
      }
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return PreferencesSetting.fromJson(data);
      }
      return PreferencesSetting.defaults();
    } catch (_) {
      return PreferencesSetting.defaults();
    }
  }
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class VibrationSettings {
  final bool enable;
  final bool onHoldChatConversation;
  final bool onNewMessage;
  final bool onGenerateToken;
  final bool onDeleteItem;

  const VibrationSettings({
    required this.enable,
    required this.onHoldChatConversation,
    required this.onNewMessage,
    required this.onGenerateToken,
    required this.onDeleteItem,
  });

  factory VibrationSettings.defaults() {
    return const VibrationSettings(
      enable: false,
      onHoldChatConversation: false,
      onNewMessage: false,
      onGenerateToken: false,
      onDeleteItem: false,
    );
  }

  VibrationSettings copyWith({
    bool? enable,
    bool? onHoldChatConversation,
    bool? onNewMessage,
    bool? onGenerateToken,
    bool? onDeleteItem,
  }) {
    return VibrationSettings(
      enable: enable ?? this.enable,
      onHoldChatConversation:
          onHoldChatConversation ?? this.onHoldChatConversation,
      onNewMessage: onNewMessage ?? this.onNewMessage,
      onGenerateToken: onGenerateToken ?? this.onGenerateToken,
      onDeleteItem: onDeleteItem ?? this.onDeleteItem,
    );
  }

  factory VibrationSettings.fromJson(Map<String, dynamic> json) =>
      _$VibrationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$VibrationSettingsToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class LanguageSetting {
  final String languageCode;
  final String? countryCode;
  final bool autoDetect;

  const LanguageSetting({
    required this.languageCode,
    this.countryCode,
    this.autoDetect = true,
  });

  factory LanguageSetting.defaults() {
    return const LanguageSetting(languageCode: 'auto', autoDetect: true);
  }

  factory LanguageSetting.fromJson(Map<String, dynamic> json) =>
      _$LanguageSettingFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageSettingToJson(this);

  Locale? getLocale() {
    if (autoDetect || languageCode == 'auto') {
      return null;
    }

    if (countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    return Locale(languageCode);
  }

  LanguageSetting copyWith({
    String? languageCode,
    String? countryCode,
    bool? autoDetect,
  }) {
    return LanguageSetting(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      autoDetect: autoDetect ?? this.autoDetect,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageSetting &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.autoDetect == autoDetect;
  }

  @override
  int get hashCode {
    return languageCode.hashCode ^ countryCode.hashCode ^ autoDetect.hashCode;
  }
}
