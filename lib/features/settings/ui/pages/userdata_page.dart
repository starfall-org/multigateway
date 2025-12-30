import 'package:flutter/material.dart';

import '../../../../app/translate/tl.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Màn hình điều khiển dữ liệu cho phép quản lý và kiểm soát dữ liệu ứng dụng
class DataControlsScreen extends StatefulWidget {
  const DataControlsScreen({super.key});

  @override
  State<DataControlsScreen> createState() => _DataControlsScreenState();
}

class _DataControlsScreenState extends State<DataControlsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: SafeArea(top: false, bottom: true, child: _buildBody()),
    );
  }

  /// Xây dựng nội dung chính của màn hình
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataOverviewCard(),
          const SizedBox(height: 24),
          _buildDataManagementSection(),
          const SizedBox(height: 24),
          _buildPrivacyControlsSection(),
          const SizedBox(height: 24),
          _buildStorageControlsSection(),
        ],
      ),
    );
  }

  /// Xây dựng card tổng quan dữ liệu
  Widget _buildDataOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Data Overview'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tl('App data statistics and information'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataStats(),
          ],
        ),
      ),
    );
  }

  /// Xây dựng thống kê dữ liệu
  Widget _buildDataStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.chat_bubble,
          label: 'Conversations',
          value: '0',
        ),
        _buildStatItem(icon: Icons.person, label: 'Profiles', value: '0'),
        _buildStatItem(icon: Icons.cloud, label: 'Providers', value: '0'),
      ],
    );
  }

  /// Xây dựng item thống kê
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Xây dựng phần quản lý dữ liệu
  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Data Management'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.backup,
                title: 'Backup Data',
                subtitle: 'Create backup of app data',
                onTap: () => _handleBackup(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.restore,
                title: 'Restore Data',
                subtitle: 'Restore from backup',
                onTap: () => _handleRestore(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.import_export,
                title: 'Export Data',
                subtitle: 'Export data to file',
                onTap: () => _handleExport(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần điều khiển quyền riêng tư
  Widget _buildPrivacyControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Privacy'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.visibility_off,
                title: 'Anonymize Data',
                subtitle: 'Remove personally identifiable information',
                onTap: () => _handleAnonymize(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.delete_forever,
                title: 'Delete All Data',
                subtitle: 'Permanently delete all app data',
                onTap: () => _handleDeleteAll(),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần điều khiển lưu trữ
  Widget _buildStorageControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Storage Controls'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildControlTile(
                icon: Icons.cleaning_services,
                title: 'Clean Cache',
                subtitle: 'Clear temporary cache files',
                onTap: () => _handleCleanCache(),
              ),
              const Divider(height: 1),
              _buildControlTile(
                icon: Icons.folder_open,
                title: 'Manage Files',
                subtitle: 'View and manage saved files',
                onTap: () => _handleManageFiles(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng tile điều khiển
  Widget _buildControlTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  /// Handlers cho các hành động
  void _handleBackup() {
    context.showInfoSnackBar(tl('Data backup started'));
  }

  void _handleRestore() {
    context.showInfoSnackBar(tl('Data restore started'));
  }

  void _handleExport() {
    context.showInfoSnackBar(tl('Data export started'));
  }

  void _handleAnonymize() {
    context.showInfoSnackBar(tl('Data anonymization started'));
  }

  void _handleDeleteAll() {
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

  void _handleCleanCache() {
    context.showSuccessSnackBar(tl('Cache cleaned'));
  }

  void _handleManageFiles() {
    context.showInfoSnackBar(tl('File manager opened'));
  }
}
