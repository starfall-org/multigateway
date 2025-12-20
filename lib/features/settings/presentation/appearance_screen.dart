import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../../core/models/appearances.dart';
import '../viewmodel/appearance_viewmodel.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/super_dark_mode_card.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late AppearanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AppearanceViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = _viewModel.settings;
    final isDark = settings.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appearance.title'.tr()),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme selection: system, light, dark, custom
          SettingsSectionHeader('settings.appearance.theme_mode'.tr()),
          const SizedBox(height: 12),
          _buildThemeSegmented(),

          // Super Dark Mode
          const SizedBox(height: 16),
          SuperDarkModeCard(
            value: settings.superDarkMode,
            onChanged: (val) => _viewModel.togglePureDark(val),
          ),

          const SizedBox(height: 24),

          // Material You toggle
          SettingsSectionHeader('settings.appearance.material_you'.tr()),
          DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final bool supported =
                  (lightDynamic != null || darkDynamic != null);
              return SettingsCard(
                child: SwitchListTile(
                  title: Text('settings.appearance.dynamic_colors'.tr()),
                  subtitle: supported
                      ? Text('settings.appearance.dynamic_colors_desc'.tr())
                      : null,
                  value: settings.dynamicColor,
                  onChanged: supported
                      ? (val) => _viewModel.toggleMaterialYou(val)
                      : null,
                ),
              );
            },
          ),

          // Secondary Background Mode
          const SizedBox(height: 12),
          SettingsSectionHeader(
            'settings.appearance.secondary_background'.tr(),
          ),
          const SizedBox(height: 12),
          _buildSecondaryBgSegmented(),

          const SizedBox(height: 24),

          // Color customization is only visible in Custom mode and disabled when Material You is enabled
          SettingsSectionHeader('settings.appearance.colors'.tr()),
          const SizedBox(height: 12),

          SettingsCard(
            child: Column(
              children: [
                _buildColorTile(
                  label: 'settings.appearance.primary_color'.tr(),
                  colorType: ColorType.primary,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.secondary_color'.tr(),
                  colorType: ColorType.secondary,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.background_color'.tr(),
                  colorType: ColorType.background,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.surface_color'.tr(),
                  colorType: ColorType.surface,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.text_color'.tr(),
                  colorType: ColorType.text,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.darkmode_text_color'.tr(),
                  colorType: ColorType.darkmodeText,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.text_hint_color'.tr(),
                  colorType: ColorType.textHint,
                ),
                const Divider(height: 1),
                _buildColorTile(
                  label: 'settings.appearance.darkmode_text_hint_color'.tr(),
                  colorType: ColorType.darkmodeTextHint,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildPreview(isDark: isDark, settings: settings),
        ],
      ),
    );
  }

  Widget _buildThemeSegmented() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeSelection>(
        segments: [
          ButtonSegment(
            value: ThemeSelection.system,
            label: const Icon(Icons.brightness_auto_outlined),
            tooltip: 'settings.appearance.system_default'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.light,
            label: const Icon(Icons.light_mode_outlined),
            tooltip: 'settings.appearance.light'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.dark,
            label: const Icon(Icons.dark_mode_outlined),
            tooltip: 'settings.appearance.dark'.tr(),
          ),
          ButtonSegment(
            value: ThemeSelection.custom,
            label: const Icon(Icons.palette_outlined),
            tooltip: 'settings.appearance.custom'.tr(),
          ),
        ],
        selected: {_viewModel.settings.selection},
        onSelectionChanged: (Set<ThemeSelection> newSelection) {
          _viewModel.updateSelection(newSelection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildSecondaryBgSegmented() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<SecondaryBackgroundMode>(
        segments: [
          ButtonSegment(
            value: SecondaryBackgroundMode.on,
            label: const Icon(Icons.layers_outlined),
            tooltip: 'settings.appearance.secondary_bg_on'.tr(),
          ),
          ButtonSegment(
            value: SecondaryBackgroundMode.auto,
            label: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'settings.appearance.secondary_bg_auto'.tr(),
          ),
          ButtonSegment(
            value: SecondaryBackgroundMode.off,
            label: const Icon(Icons.layers_clear_outlined),
            tooltip: 'settings.appearance.secondary_bg_off'.tr(),
          ),
        ],
        selected: {_viewModel.settings.secondaryBackgroundMode},
        onSelectionChanged: (Set<SecondaryBackgroundMode> newSelection) {
          _viewModel.updateSecondaryBackgroundMode(newSelection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }

  Widget _buildColorTile({
    required String label,
    required ColorType colorType,
  }) {
    final currentColor = Color(_viewModel.getColor(colorType));
    return ListTile(
      title: Text(label),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      onTap: () {
        _showColorPickerDialog(context, colorType, currentColor);
      },
    );
  }

  void _showColorPickerDialog(
    BuildContext context,
    ColorType colorType,
    Color currentColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: currentColor,
        onColorSelected: (color) {
          _viewModel.updateColor(colorType, color.toARGB32());
        },
      ),
    );
  }

  Widget _buildPreview({
    required bool isDark,
    required Appearances settings,
  }) {
    final primary = Color(settings.primaryColor);
    final onSurface = isDark ? Colors.white : Colors.black;
    final surface = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SettingsCard(
          backgroundColor: surface,
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF424242) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'settings.appearance.preview_subtitle'.tr(),
                      style: TextStyle(color: onSurface, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 240),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'settings.appearance.preview_button'.tr(),
                      style: TextStyle(
                        color: primary.computeLuminance() < 0.5
                            ? Colors.white
                            : Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
