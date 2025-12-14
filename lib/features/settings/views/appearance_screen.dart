import 'package:flutter/material.dart';
import '../../../core/storage/theme_repository.dart';
import '../../../core/models/settings/theme.dart';

import 'package:easy_localization/easy_localization.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late ThemeRepository _repository;
  ThemeSettings _settings = ThemeSettings.defaults();
  bool _isLoading = true;

  final List<Color> _brandColors = [
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _repository = await ThemeRepository.init();
    setState(() {
      _settings = _repository.currentTheme;
      _isLoading = false;
    });
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    final newSettings = _settings.copyWith(themeMode: mode);
    await _repository.updateSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  Future<void> _updateColor(int colorValue) async {
    final newSettings = _settings.copyWith(colorValue: colorValue);
    await _repository.updateSettings(newSettings);
    setState(() {
      _settings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appearance'.tr()),
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
          SettingsSectionHeader('settings.theme_mode'.tr()),
          const SizedBox(height: 8),
          _buildThemeModeSelector(),
          const SizedBox(height: 24),
          SettingsSectionHeader('settings.brand_color'.tr()),
          const SizedBox(height: 8),
          _buildColorSelector(),
          const SizedBox(height: 24),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector() {
    return SettingsCard(
      child: RadioGroup<ThemeMode>(
        groupValue: _settings.themeMode,
        onChanged: (val) {
          if (val != null) {
            _updateThemeMode(val);
          }
        },
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              title: Text('settings.system_default'.tr()),
              value: ThemeMode.system,
            ),
            RadioListTile<ThemeMode>(
              title: Text('settings.light'.tr()),
              value: ThemeMode.light,
            ),
            RadioListTile<ThemeMode>(
              title: Text('settings.dark'.tr()),
              value: ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _brandColors.map((color) {
        final isSelected = _settings.colorValue == color.toARGB32();
        return GestureDetector(
          onTap: () => _updateColor(color.toARGB32()),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.grey.shade800, width: 3)
                  : null,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview() {
    final color = Color(_settings.colorValue);
    return SettingsCard(
      backgroundColor: _settings.themeMode == ThemeMode.dark
          ? Colors.grey[900]
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings.preview_title'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _settings.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Text(
                      'settings.preview_subtitle'.tr(),
                      style: TextStyle(
                        color: _settings.themeMode == ThemeMode.dark
                            ? Colors.grey
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: Text('settings.preview_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
