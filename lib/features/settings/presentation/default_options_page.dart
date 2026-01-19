import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/default_options_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/settings_card.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';

/// Trang cấu hình default models/profile cho ứng dụng
class DefaultOptionsPage extends StatelessWidget {
  const DefaultOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultOptionsControllerScope(
      child: const _DefaultOptionsView(),
    );
  }
}

class _DefaultOptionsView extends StatelessWidget {
  const _DefaultOptionsView();

  @override
  Widget build(BuildContext context) {
    final controller = DefaultOptionsControllerProvider.of(context);
    final initFuture =
        DefaultOptionsControllerProvider.initializationFutureOf(context);
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
              tl('Default Options'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Define default models and profile'),
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
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Watch((context) {
              final isSaving = controller.isSaving.value;
              final profiles = controller.profiles.value;
              final selectedProfileId = controller.selectedProfileId.value;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tl('Default profile'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: selectedProfileId ?? '',
                              items: [
                                DropdownMenuItem(
                                  value: '',
                                  child: Text(tl('None')),
                                ),
                                ...profiles.map(
                                  (profile) => DropdownMenuItem(
                                    value: profile.id,
                                    child: Text(profile.name),
                                  ),
                                ),
                              ],
                              onChanged: (value) =>
                                  controller.updateSelectedProfile(value),
                              decoration: InputDecoration(
                                labelText: tl('Profile'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tl('Default models'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ModelFields(
                              title: tl('Chat model'),
                              providerController:
                                  controller.chatProviderController,
                              modelController: controller.chatModelController,
                            ),
                            const SizedBox(height: 16),
                            _ModelFields(
                              title: tl('Translation model'),
                              providerController:
                                  controller.translationProviderController,
                              modelController:
                                  controller.translationModelController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving
                                ? null
                                : () => _handleSave(context, controller),
                            child: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(tl('Save defaults')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed:
                              isSaving ? null : () => _handleReset(context, controller),
                          child: Text(tl('Reset')),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

/// Provider + scope để khởi tạo/dispose controller
class DefaultOptionsControllerScope extends StatefulWidget {
  final Widget child;
  const DefaultOptionsControllerScope({super.key, required this.child});

  @override
  State<DefaultOptionsControllerScope> createState() =>
      _DefaultOptionsControllerScopeState();
}

class _DefaultOptionsControllerScopeState
    extends State<DefaultOptionsControllerScope> {
  late final DefaultOptionsController _controller;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = DefaultOptionsController();
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultOptionsControllerProvider(
      controller: _controller,
      initializationFuture: _initFuture,
      child: widget.child,
    );
  }
}

class DefaultOptionsControllerProvider extends InheritedWidget {
  final DefaultOptionsController controller;
  final Future<void> initializationFuture;

  const DefaultOptionsControllerProvider({
    super.key,
    required this.controller,
    required this.initializationFuture,
    required super.child,
  });

  static DefaultOptionsController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DefaultOptionsControllerProvider>();
    assert(provider != null, 'DefaultOptionsControllerProvider not found in context');
    return provider!.controller;
  }

  static Future<void> initializationFutureOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<DefaultOptionsControllerProvider>();
    assert(provider != null, 'DefaultOptionsControllerProvider not found in context');
    return provider!.initializationFuture;
  }

  @override
  bool updateShouldNotify(covariant DefaultOptionsControllerProvider oldWidget) {
    return false;
  }
}

Future<void> _handleSave(
  BuildContext context,
  DefaultOptionsController controller,
) async {
  final error = await controller.saveDefaults();
  if (!context.mounted) return;
  if (error != null) {
    context.showInfoSnackBar(tl(error));
  } else {
    context.showSuccessSnackBar(tl('Default options saved'));
  }
}

Future<void> _handleReset(
  BuildContext context,
  DefaultOptionsController controller,
) async {
  await controller.resetDefaults();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Defaults reset'));
}

class _ModelFields extends StatelessWidget {
  final String title;
  final TextEditingController providerController;
  final TextEditingController modelController;

  const _ModelFields({
    required this.title,
    required this.providerController,
    required this.modelController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: providerController,
          decoration: InputDecoration(
            labelText: tl('Provider ID'),
            hintText: 'openai, anthropic...',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: modelController,
          decoration: InputDecoration(
            labelText: tl('Model ID'),
            hintText: 'gpt-4o, claude-3...',
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
