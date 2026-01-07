import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/widgets/update/current_version_card.dart';
import 'package:multigateway/features/settings/ui/widgets/update/update_available_card.dart';
import 'package:multigateway/features/settings/ui/widgets/update/update_history_section.dart';
import 'package:multigateway/features/settings/ui/widgets/update/update_status_card.dart';
import 'package:multigateway/shared/utils/app_version.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình cập nhật ứng dụng
class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _isCheckingForUpdates = false;
  bool _hasUpdate = false;
  String _currentVersion = '0.0.0';
  final String _latestVersion = '0.0.0';

  @override
  void initState() {
    super.initState();
    getAppVersion().then((version) {
      setState(() {
        _currentVersion = version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Update'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Check and install updates'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _checkForUpdates,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CurrentVersionCard(version: _currentVersion),
              const SizedBox(height: 24),
              UpdateStatusCard(
                isChecking: _isCheckingForUpdates,
                hasUpdate: _hasUpdate,
                onCheckTap: _checkForUpdates,
              ),
              const SizedBox(height: 24),
              if (_hasUpdate)
                UpdateAvailableCard(
                  latestVersion: _latestVersion,
                  onSkipTap: _skipUpdate,
                  onDownloadTap: _downloadUpdate,
                ),
              if (_hasUpdate) const SizedBox(height: 24),
              const UpdateHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Kiểm tra cập nhật
  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingForUpdates = true;
    });

    // Simulate checking for updates
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCheckingForUpdates = false;
      _hasUpdate = true; // Simulate finding an update
    });

    if (mounted) {
      context.showInfoSnackBar(tl('Check update completed'));
    }
  }

  /// Bỏ qua cập nhật
  void _skipUpdate() {
    context.showInfoSnackBar(tl('Skip update'));
  }

  /// Tải xuống cập nhật
  void _downloadUpdate() {
    context.showInfoSnackBar(tl('Download update started'));
  }
}
