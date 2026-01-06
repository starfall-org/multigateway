import 'package:flutter/material.dart';

import '../../../../app/translate/tl.dart';
import '../../../../shared/utils/app_version.dart';

/// Màn hình cập nhật ứng dụng
class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
          _buildCurrentVersionCard(),
          const SizedBox(height: 24),
          _buildUpdateStatusCard(),
          const SizedBox(height: 24),
          if (_hasUpdate) _buildUpdateAvailableCard(),
          if (_hasUpdate) const SizedBox(height: 24),
          _buildUpdateHistorySection(),
        ],
      ),
    );
  }

  /// Xây dựng card phiên bản hiện tại
  Widget _buildCurrentVersionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Current Version'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tl('Current app version information'),
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
            _buildVersionInfo('Version Number', _currentVersion),
            const SizedBox(height: 8),
            _buildVersionInfo('Build Date', '2024-12-21'),
            const SizedBox(height: 8),
            _buildVersionInfo('Update Channel', 'Stable'),
          ],
        ),
      ),
    );
  }

  /// Xây dựng thông tin phiên bản
  Widget _buildVersionInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  /// Xây dựng card trạng thái cập nhật
  Widget _buildUpdateStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Check for Updates'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasUpdate ? 'Update available' : 'Up to date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _hasUpdate
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCheckingForUpdates ? null : _checkForUpdates,
                icon: _isCheckingForUpdates
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  _isCheckingForUpdates ? 'Checking...' : 'Check Now',
                ),
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color:
                        Theme.of(
                          context,
                        ).inputDecorationTheme.hintStyle?.color ??
                        Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng card có cập nhật
  Widget _buildUpdateAvailableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.new_releases,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Placholder text'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Placholder text'}: $_latestVersion',
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
            _buildUpdateFeatures(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _skipUpdate(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            Theme.of(
                              context,
                            ).inputDecorationTheme.hintStyle?.color ??
                            Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Text(tl('Skip this version')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _downloadUpdate(),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color:
                            Theme.of(
                              context,
                            ).inputDecorationTheme.hintStyle?.color ??
                            Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: Text(tl('Download Update')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng danh sách tính năng cập nhật
  Widget _buildUpdateFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('What\'s New'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...['Coming soon', 'Coming soon', 'Coming soon'].map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(feature)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Xây dựng phần lịch sử cập nhật
  Widget _buildUpdateHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Update History'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildHistoryItem(
                version: '0.0.0',
                date: DateTime.now().toString(),
                features: [
                  'No update history',
                  "This feature will be added in the future",
                ],
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ],
    );
  }

  /// Xây dựng item lịch sử
  Widget _buildHistoryItem({
    required String version,
    required String date,
    required List<String> features,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tl('v$version'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(date, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            ),
          ),
        ],
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
