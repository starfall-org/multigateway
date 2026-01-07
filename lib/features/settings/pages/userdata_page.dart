import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/ui/widgets/userdata/data_management_section.dart';
import 'package:multigateway/features/settings/ui/widgets/userdata/data_overview_card.dart';
import 'package:multigateway/features/settings/ui/widgets/userdata/privacy_controls_section.dart';
import 'package:multigateway/features/settings/ui/widgets/userdata/storage_controls_section.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Màn hình điều khiển dữ liệu cho phép quản lý và kiểm soát dữ liệu ứng dụng
class DataControlsScreen extends StatelessWidget {
  const DataControlsScreen({super.key});

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
              tl('Data Controls'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Manage and control data'),
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
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DataOverviewCard(),
              const SizedBox(height: 24),
              DataManagementSection(
                onBackupTap: () => _handleBackup(context),
                onRestoreTap: () => _handleRestore(context),
                onExportTap: () => _handleExport(context),
              ),
              const SizedBox(height: 24),
              PrivacyControlsSection(
                onAnonymizeTap: () => _handleAnonymize(context),
                onDeleteAllTap: () => _handleDeleteAll(context),
              ),
              const SizedBox(height: 24),
              StorageControlsSection(
                onCleanCacheTap: () => _handleCleanCache(context),
                onManageFilesTap: () => _handleManageFiles(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handlers cho các hành động
  static void _handleBackup(BuildContext context) {
    context.showInfoSnackBar(tl('Data backup started'));
  }

  static void _handleRestore(BuildContext context) {
    context.showInfoSnackBar(tl('Data restore started'));
  }

  static void _handleExport(BuildContext context) {
    context.showInfoSnackBar(tl('Data export started'));
  }

  static void _handleAnonymize(BuildContext context) {
    context.showInfoSnackBar(tl('Data anonymization started'));
  }

  static void _handleDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tl('Confirm Delete All')),
        content: Text(
          tl(
            'This action will permanently delete all app data. Are you sure you want to continue?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tl('Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.showSuccessSnackBar(tl('All data deleted'));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color:
                    Theme.of(context).inputDecorationTheme.hintStyle?.color ??
                        Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            child: Text(tl('Delete')),
          ),
        ],
      ),
    );
  }

  static void _handleCleanCache(BuildContext context) {
    context.showSuccessSnackBar(tl('Cache cleaned'));
  }

  static void _handleManageFiles(BuildContext context) {
    context.showInfoSnackBar(tl('File manager opened'));
  }
}
