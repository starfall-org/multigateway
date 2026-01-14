import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/appearance_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/appearance_controller_provider.dart';
import 'package:multigateway/features/settings/presentation/widgets/color_picker_dialog.dart';

/// Widget chọn color scheme
class ColorSchemeSelector extends StatelessWidget {
  const ColorSchemeSelector({super.key});

  String _getPresetName(ColorSchemePreset preset) {
    return switch (preset) {
      ColorSchemePreset.blue => tl('Blue'),
      ColorSchemePreset.purple => tl('Purple'),
      ColorSchemePreset.green => tl('Green'),
      ColorSchemePreset.orange => tl('Orange'),
      ColorSchemePreset.pink => tl('Pink'),
      ColorSchemePreset.red => tl('Red'),
      ColorSchemePreset.teal => tl('Teal'),
      ColorSchemePreset.indigo => tl('Indigo'),
      ColorSchemePreset.custom => tl('Custom'),
    };
  }

  Color _getPresetPrimaryColor(ColorSchemePreset preset) {
    return switch (preset) {
      ColorSchemePreset.blue => Colors.blue,
      ColorSchemePreset.purple => Colors.purple,
      ColorSchemePreset.green => Colors.green,
      ColorSchemePreset.orange => Colors.orange,
      ColorSchemePreset.pink => Colors.pink,
      ColorSchemePreset.red => Colors.red,
      ColorSchemePreset.teal => Colors.teal,
      ColorSchemePreset.indigo => Colors.indigo,
      ColorSchemePreset.custom => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppearanceControllerProvider.of(context);
    final theme = Theme.of(context);

    // Chỉ hiển thị khi dynamic color tắt
    if (controller.settings.dynamicColor) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Color Scheme'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tl('Choose a color scheme'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ColorSchemePreset.values.map((preset) {
                    final isSelected =
                        controller.settings.colorSchemePreset == preset;
                    final presetColor = _getPresetPrimaryColor(preset);

                    return _ColorSchemeChip(
                      label: _getPresetName(preset),
                      color: presetColor,
                      isSelected: isSelected,
                      isCustom: preset == ColorSchemePreset.custom,
                      onTap: () => controller.updateColorSchemePreset(preset),
                    );
                  }).toList(),
                ),
                // Hiển thị custom color pickers khi chọn Custom
                if (controller.settings.colorSchemePreset ==
                    ColorSchemePreset.custom) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    tl('Custom Colors'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CustomColorPickers(controller: controller),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorSchemeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback onTap;

  const _ColorSchemeChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isCustom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCustom) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ] else ...[
              Icon(
                Icons.palette_outlined,
                size: 20,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomColorPickers extends StatelessWidget {
  final AppearanceController controller;

  const _CustomColorPickers({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ColorPickerTile(
          label: tl('Primary Color'),
          color: Color(controller.getColor(ColorType.primary)),
          onTap: () => _showColorPicker(context, ColorType.primary, controller),
        ),
        const SizedBox(height: 12),
        _ColorPickerTile(
          label: tl('Secondary Color'),
          color: Color(controller.getColor(ColorType.secondary)),
          onTap: () =>
              _showColorPicker(context, ColorType.secondary, controller),
        ),
        const SizedBox(height: 12),
        _ColorPickerTile(
          label: tl('Background Color'),
          color: Color(controller.getColor(ColorType.background)),
          onTap: () =>
              _showColorPicker(context, ColorType.background, controller),
        ),
        const SizedBox(height: 12),
        _ColorPickerTile(
          label: tl('Surface Color'),
          color: Color(controller.getColor(ColorType.surface)),
          onTap: () => _showColorPicker(context, ColorType.surface, controller),
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    ColorType type,
    AppearanceController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: Color(controller.getColor(type)),
        onColorSelected: (color) {
          controller.updateColor(type, color.toARGB32());
        },
      ),
    );
  }
}

class _ColorPickerTile extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorPickerTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Icon(
              Icons.edit_outlined,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
