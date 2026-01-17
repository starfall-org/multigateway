import 'package:flutter/material.dart';
import 'package:multigateway/app/models/appearance_setting.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/appearance_controller_provider.dart';

/// Widget chọn theme mode
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppearanceControllerProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Theme Mode'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _ThemeOption(
                title: 'System',
                subtitle: 'Follow system theme',
                icon: Icons.brightness_auto,
                isSelected:
                    controller.settings.value.selection ==
                    ThemeSelection.system,
                onTap: () => controller.updateSelection(ThemeSelection.system),
              ),
              const Divider(height: 1),
              _ThemeOption(
                title: 'Light',
                subtitle: 'Light theme',
                icon: Icons.light_mode,
                isSelected:
                    controller.settings.value.selection == ThemeSelection.light,
                onTap: () => controller.updateSelection(ThemeSelection.light),
              ),
              const Divider(height: 1),
              _ThemeOption(
                title: 'Dark',
                subtitle: 'Dark theme',
                icon: Icons.dark_mode,
                isSelected:
                    controller.settings.value.selection == ThemeSelection.dark,
                onTap: () => controller.updateSelection(ThemeSelection.dark),
              ),
              const Divider(height: 1),
              _ThemeOption(
                title: 'Custom',
                subtitle: 'Customize colors',
                icon: Icons.palette,
                isSelected:
                    controller.settings.value.selection ==
                    ThemeSelection.custom,
                onTap: () => controller.updateSelection(ThemeSelection.custom),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget option cho theme
class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
