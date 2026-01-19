import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/update_controller.dart';
import 'package:multigateway/features/settings/presentation/widgets/update/current_version_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/update/update_available_card.dart';
import 'package:multigateway/features/settings/presentation/widgets/update/update_history_section.dart';
import 'package:multigateway/features/settings/presentation/widgets/update/update_status_card.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Màn hình cập nhật ứng dụng
class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return UpdateControllerScope(
      child: const _UpdateView(),
    );
  }
}

class _UpdateView extends StatelessWidget {
  const _UpdateView();

  @override
  Widget build(BuildContext context) {
    final controller = UpdateControllerProvider.of(context);
    final initFuture = UpdateControllerProvider.initializationFutureOf(context);
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
              tl('Update'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Check and install updates'),
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: () => _handleCheckForUpdates(context, controller),
          ),
        ],
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrentVersionCard(
                      version: controller.currentVersion.value,
                      lastCheckedAt: controller.lastCheckedAt.value,
                    ),
                    const SizedBox(height: 24),
                    UpdateStatusCard(
                      isChecking: controller.isChecking.value,
                      hasUpdate: controller.hasUpdate.value,
                      onCheckTap: () => _handleCheckForUpdates(context, controller),
                      onOpenReleaseTap: () => _handleOpenRelease(context, controller),
                    ),
                    const SizedBox(height: 24),
                    if (controller.hasUpdate.value)
                      UpdateAvailableCard(
                        latestVersion: controller.latestVersion.value,
                        releaseName: controller.latestRelease.value?.name,
                        publishedAt: controller.latestRelease.value?.publishedAt,
                        highlights: controller.latestRelease.value?.highlights ?? const [],
                        onOpenReleaseTap: () => _handleOpenRelease(context, controller),
                        onSkipTap: () => _handleSkipUpdate(context, controller),
                        onDownloadTap: () => _handleDownloadUpdate(context, controller),
                      ),
                    if (controller.hasUpdate.value) const SizedBox(height: 24),
                    UpdateHistorySection(
                      releases: controller.releases.value,
                      isLoading: controller.isChecking.value &&
                          controller.releases.value.isEmpty,
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
class UpdateControllerScope extends StatefulWidget {
  final Widget child;
  const UpdateControllerScope({super.key, required this.child});

  @override
  State<UpdateControllerScope> createState() => _UpdateControllerScopeState();
}

class _UpdateControllerScopeState extends State<UpdateControllerScope> {
  late final UpdateController _controller;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = UpdateController();
    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateControllerProvider(
      controller: _controller,
      initializationFuture: _initFuture,
      child: widget.child,
    );
  }
}

class UpdateControllerProvider extends InheritedWidget {
  final UpdateController controller;
  final Future<void> initializationFuture;

  const UpdateControllerProvider({
    super.key,
    required this.controller,
    required this.initializationFuture,
    required super.child,
  });

  static UpdateController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UpdateControllerProvider>();
    assert(provider != null, 'UpdateControllerProvider not found in context');
    return provider!.controller;
  }

  static Future<void> initializationFutureOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<UpdateControllerProvider>();
    assert(provider != null, 'UpdateControllerProvider not found in context');
    return provider!.initializationFuture;
  }

  @override
  bool updateShouldNotify(covariant UpdateControllerProvider oldWidget) {
    return false;
  }
}

Future<void> _handleCheckForUpdates(
  BuildContext context,
  UpdateController controller,
) async {
  await controller.checkForUpdates();
  if (!context.mounted) return;

  if (controller.lastError.value != null) {
    context.showErrorSnackBar(controller.lastError.value!);
    return;
  }

  if (controller.hasUpdate.value) {
    context.showSuccessSnackBar(tl('Update available!'));
  } else {
    context.showInfoSnackBar(tl('You are on the latest version'));
  }
}

void _handleSkipUpdate(
  BuildContext context,
  UpdateController controller,
) {
  controller.skipUpdate();
  if (!context.mounted) return;
  context.showInfoSnackBar(tl('Update skipped'));
}

Future<void> _handleDownloadUpdate(
  BuildContext context,
  UpdateController controller,
) async {
  final uri = await controller.resolveDownloadUrl();
  if (!context.mounted) return;

  if (uri == null) {
    context.showErrorSnackBar(tl('No download link available for this release'));
    return;
  }

  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted) return;

  if (!launched) {
    context.showErrorSnackBar(tl('Could not open download link'));
    return;
  }

  context.showSuccessSnackBar(tl('Opening download link...'));
}

Future<void> _handleOpenRelease(
  BuildContext context,
  UpdateController controller,
) async {
  final uri = controller.releasePageUrl;
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted) return;

  if (!launched) {
    context.showErrorSnackBar(tl('Could not open release page'));
  }
}
