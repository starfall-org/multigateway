import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/controllers/appearance_controller.dart';
import 'package:multigateway/features/settings/ui/widgets/color_picker_dialog.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_card.dart';
import 'package:multigateway/features/settings/ui/widgets/settings_section_header.dart';
import 'package:multigateway/features/settings/ui/widgets/superdarkmode_card.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
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
        title: Text(tl('Appearance')),
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
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Theme selection: system, light, dark, custom
            SettingsSectionHeader(tl('Mode')),
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
            SettingsSectionHeader(tl('Colors')),
            DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                final bool supported =
                    (lightDynamic != null || darkDynamic != null);
                return SettingsCard(
                  child: SwitchListTile(
                    title: Text(tl('Dynamic Colors')),
                    subtitle: supported
                        ? Text(tl('Use system dynamic colors'))
                        : null,
                    value: settings.dynamicColor,
                    onChanged: supported
                        ? (val) => _viewModel.toggleMaterialYou(val)
                        : null,
                  ),
                );
              },
            ),

            // Color customization is only visible in Custom mode and disabled when Material You is enabled
            SettingsSectionHeader('settings.appearance.colors'),
            const SizedBox(height: 12),

            SettingsCard(
              child: Column(
                children: [
                  _buildColorTile(
                    label: tl('Primary Color'),
                    colorType: ColorType.primary,
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    label: tl('Secondary Color'),
                    colorType: ColorType.secondary,
                  ),
                  const Divider(height: 1),
                  _viewModel.settings.selection == ThemeSelection.custom
                      ? _buildColorTile(
                          label: tl('Background Color'),
                          colorType: ColorType.background,
                        )
                      : AbsorbPointer(
                          child: _buildColorTile(
                            label: tl('Background Color'),
                            colorType: ColorType.background,
                          ),
                        ),

                  const Divider(height: 1),
                  _buildColorTile(
                    label: tl('Surface Color'),
                    colorType: ColorType.surface,
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    label: tl('Text Color'),
                    colorType: ColorType.text,
                  ),
                  const Divider(height: 1),
                  _buildColorTile(
                    label: tl('Text Hint Color'),
                    colorType: ColorType.textHint,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildPreview(isDark: isDark, settings: settings),
          ],
        ),
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
            tooltip: tl('System Default'),
          ),
          ButtonSegment(
            value: ThemeSelection.light,
            label: const Icon(Icons.light_mode_outlined),
            tooltip: tl('Light'),
          ),
          ButtonSegment(
            value: ThemeSelection.dark,
            label: const Icon(Icons.dark_mode_outlined),
            tooltip: tl('Dark'),
          ),
          ButtonSegment(
            value: ThemeSelection.custom,
            label: const Icon(Icons.palette_outlined),
            tooltip: tl('Custom'),
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
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
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
    required AppearanceSetting settings,
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
                      tl('Subtitle goes here'),
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
                      tl('Primary Button'),
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
