import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/widgets/appearance/appearance_controller_provider.dart';

/// Section cài đặt bổ sung cho appearance
class AdditionalSettingsSection extends StatelessWidget {
  const AdditionalSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppearanceControllerProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Additional Settings'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(tl('Super Dark Mode')),
                subtitle: Text(tl('Use pure black background in dark mode')),
                value: controller.settings.superDarkMode,
                onChanged: (value) => controller.togglePureDark(value),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: Text(tl('Dynamic Colors')),
                subtitle: Text(tl('Use dynamic colors from wallpaper')),
                value: controller.settings.dynamicColor,
                onChanged: (value) => controller.toggleMaterialYou(value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
