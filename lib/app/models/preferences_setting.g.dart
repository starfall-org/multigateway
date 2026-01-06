// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreferencesSetting _$PreferencesSettingFromJson(Map<String, dynamic> json) =>
    PreferencesSetting(
      persistChatSelection: json['persist_chat_selection'] as bool,
      vibrationSettings: VibrationSettings.fromJson(
          json['vibration_settings'] as Map<String, dynamic>),
      languageSetting: LanguageSetting.fromJson(
          json['language_setting'] as Map<String, dynamic>),
      hideStatusBar: json['hide_status_bar'] as bool? ?? false,
      hideNavigationBar: json['hide_navigation_bar'] as bool? ?? false,
      debugMode: json['debug_mode'] as bool? ?? false,
      hasInitializedIcons: json['has_initialized_icons'] as bool? ?? false,
    );

Map<String, dynamic> _$PreferencesSettingToJson(PreferencesSetting instance) =>
    <String, dynamic>{
      'persist_chat_selection': instance.persistChatSelection,
      'vibration_settings': instance.vibrationSettings.toJson(),
      'hide_status_bar': instance.hideStatusBar,
      'hide_navigation_bar': instance.hideNavigationBar,
      'debug_mode': instance.debugMode,
      'has_initialized_icons': instance.hasInitializedIcons,
      'language_setting': instance.languageSetting.toJson(),
    };

VibrationSettings _$VibrationSettingsFromJson(Map<String, dynamic> json) =>
    VibrationSettings(
      enable: json['enable'] as bool,
      onHoldChatConversation: json['on_hold_chat_conversation'] as bool,
      onNewMessage: json['on_new_message'] as bool,
      onGenerateToken: json['on_generate_token'] as bool,
      onDeleteItem: json['on_delete_item'] as bool,
    );

Map<String, dynamic> _$VibrationSettingsToJson(VibrationSettings instance) =>
    <String, dynamic>{
      'enable': instance.enable,
      'on_hold_chat_conversation': instance.onHoldChatConversation,
      'on_new_message': instance.onNewMessage,
      'on_generate_token': instance.onGenerateToken,
      'on_delete_item': instance.onDeleteItem,
    };

LanguageSetting _$LanguageSettingFromJson(Map<String, dynamic> json) =>
    LanguageSetting(
      languageCode: json['language_code'] as String,
      countryCode: json['country_code'] as String?,
      autoDetect: json['auto_detect'] as bool? ?? true,
    );

Map<String, dynamic> _$LanguageSettingToJson(LanguageSetting instance) =>
    <String, dynamic>{
      'language_code': instance.languageCode,
      'country_code': instance.countryCode,
      'auto_detect': instance.autoDetect,
    };
