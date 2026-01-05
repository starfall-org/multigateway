import 'dart:convert';
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
  final String? activeSidebar;

  const PreferencesSetting({
    required this.persistChatSelection,
    required this.vibrationSettings,
    this.hideStatusBar = false,
    this.hideNavigationBar = false,
    this.debugMode = false,
    this.hasInitializedIcons = false,
    this.activeSidebar,
  });

  factory PreferencesSetting.defaults() {
    return PreferencesSetting(
      persistChatSelection: false,
      vibrationSettings: VibrationSettings.defaults(),
      hideStatusBar: false,
      hideNavigationBar: false,
      debugMode: false,
      hasInitializedIcons: false,
      activeSidebar: null,
    );
  }

  PreferencesSetting copyWith({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
    bool? hasInitializedIcons,
    String? activeSidebar,
  }) {
    return PreferencesSetting(
      persistChatSelection: persistChatSelection ?? this.persistChatSelection,
      vibrationSettings: vibrationSettings ?? this.vibrationSettings,
      hideStatusBar: hideStatusBar ?? this.hideStatusBar,
      hideNavigationBar: hideNavigationBar ?? this.hideNavigationBar,
      debugMode: debugMode ?? this.debugMode,
      hasInitializedIcons: hasInitializedIcons ?? this.hasInitializedIcons,
      activeSidebar: activeSidebar ?? this.activeSidebar,
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

@JsonSerializable(fieldRename: FieldRename.snake)
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
