import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/appearance_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/additional_settings_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/appearance_controller_provider.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/color_scheme_selector.dart';
import 'package:multigateway/features/settings/presentation/widgets/appearance/theme_mode_selector.dart';
import 'package:signals/signals_flutter.dart';

/// Màn hình cài đặt giao diện
class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late final AppearanceController _controller;
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _controller = AppearanceController();
    _initializationFuture = _controller.initializationFuture;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Appearance'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Customize app appearance'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<void>(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return AppearanceControllerProvider(
              controller: _controller,
              child: Watch((context) {
                // Watch settings signal to rebuild when it changes
                _controller.settings.value;
                return const SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeModeSelector(),
                      SizedBox(height: 24),
                      AdditionalSettingsSection(),
                      SizedBox(height: 24),
                      ColorSchemeSelector(),
                    ],
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
