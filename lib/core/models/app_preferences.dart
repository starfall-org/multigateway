import 'dart:convert';

/// App-wide preferences that are not language/theme related.
/// - persistChatSelection: when true, persist selected provider/model and enabled tools per conversation
/// - preferAgentSettings: when true, agent-level overrides take precedence over global preferences
class AppPreferences {
  final bool persistChatSelection;
  final VibrationSettings vibrationSettings;
  final bool hideStatusBar;
  final bool hideNavigationBar;
  final bool debugMode;
  final bool hasInitializedIcons;

  const AppPreferences({
    required this.persistChatSelection,
    required this.vibrationSettings,
    this.hideStatusBar = false,
    this.hideNavigationBar = false,
    this.debugMode = false,
    this.hasInitializedIcons = false,
  });

  factory AppPreferences.defaults() {
    return AppPreferences(
      persistChatSelection: false,
      vibrationSettings: VibrationSettings.defaults(),
      hideStatusBar: false,
      hideNavigationBar: false,
      debugMode: false,
      hasInitializedIcons: false,
    );
  }

  AppPreferences copyWith({
    bool? persistChatSelection,
    VibrationSettings? vibrationSettings,
    bool? hideStatusBar,
    bool? hideNavigationBar,
    bool? debugMode,
    bool? hasInitializedIcons,
  }) {
    return AppPreferences(
      persistChatSelection: persistChatSelection ?? this.persistChatSelection,
      vibrationSettings: vibrationSettings ?? this.vibrationSettings,
      hideStatusBar: hideStatusBar ?? this.hideStatusBar,
      hideNavigationBar: hideNavigationBar ?? this.hideNavigationBar,
      debugMode: debugMode ?? this.debugMode,
      hasInitializedIcons: hasInitializedIcons ?? this.hasInitializedIcons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'persistChatSelection': persistChatSelection,
      'vibrationSettings': vibrationSettings.toJson(),
      'hideStatusBar': hideStatusBar,
      'hideNavigationBar': hideNavigationBar,
      'debugMode': debugMode,
      'hasInitializedIcons': hasInitializedIcons,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      persistChatSelection: (json['persistChatSelection'] as bool?) ?? false,
      vibrationSettings: VibrationSettings.fromJson(json['vibrationSettings']),
      hideStatusBar: (json['hideStatusBar'] as bool?) ?? false,
      hideNavigationBar: (json['hideNavigationBar'] as bool?) ?? false,
      debugMode: (json['debugMode'] as bool?) ?? false,
      hasInitializedIcons: (json['hasInitializedIcons'] as bool?) ?? false,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory AppPreferences.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) {
        return AppPreferences.defaults();
      }
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return AppPreferences.fromJson(data);
      }
      return AppPreferences.defaults();
    } catch (_) {
      return AppPreferences.defaults();
    }
  }
}

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

  static VibrationSettings fromJson(Map<String, dynamic> json) {
    return VibrationSettings(
      enable: (json['enable'] as bool?) ?? false,
      onHoldChatConversation:
          (json['onHoldChatConversation'] as bool?) ?? false,
      onNewMessage: (json['onNewMessage'] as bool?) ?? false,
      onGenerateToken: (json['onGenerateToken'] as bool?) ?? false,
      onDeleteItem: (json['onDeleteItem'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enable': enable,
      'onHoldChatConversation': onHoldChatConversation,
      'onNewMessage': onNewMessage,
      'onGenerateToken': onGenerateToken,
      'onDeleteItem': onDeleteItem,
    };
  }
}
