import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Card hiển thị thông tin cập nhật có sẵn
class UpdateAvailableCard extends StatelessWidget {
  final String latestVersion;
  final VoidCallback onSkipTap;
  final VoidCallback onDownloadTap;
  final VoidCallback? onOpenReleaseTap;
  final List<String> highlights;
  final String? releaseName;
  final DateTime? publishedAt;

  const UpdateAvailableCard({
    super.key,
    required this.latestVersion,
    required this.onSkipTap,
    required this.onDownloadTap,
    required this.highlights,
    this.onOpenReleaseTap,
    this.releaseName,
    this.publishedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Update available'),
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        releaseName?.isNotEmpty == true
                            ? releaseName!
                            : '${tl('Latest version')}: $latestVersion',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      if (publishedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${tl('Published at')}: ${_formatDate(publishedAt!)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _UpdateFeatures(features: highlights, theme: theme),
            const SizedBox(height: 16),
            _ActionButtons(
              onDownloadTap: onDownloadTap,
              onSkipTap: onSkipTap,
              onOpenReleaseTap: onOpenReleaseTap,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị danh sách tính năng mới
class _UpdateFeatures extends StatelessWidget {
  final List<String> features;
  final ThemeData theme;

  const _UpdateFeatures({
    required this.features,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final displayFeatures = features.isEmpty
        ? <String>[tl('No release notes provided')]
        : features;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('What\'s New'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...displayFeatures.map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
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
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final formatted = local.toIso8601String();
  // Keep it compact: YYYY-MM-DD HH:MM:SS
  final withoutMillis = formatted.split('.').first;
  return withoutMillis.replaceFirst('T', ' ');
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onDownloadTap;
  final VoidCallback onSkipTap;
  final VoidCallback? onOpenReleaseTap;
  final ThemeData theme;

  const _ActionButtons({
    required this.onDownloadTap,
    required this.onSkipTap,
    required this.onOpenReleaseTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onOpenReleaseTap,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.inputDecorationTheme.hintStyle?.color ??
                        theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Text(tl('Open GitHub Release')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onDownloadTap,
                style: ElevatedButton.styleFrom(
                  side: BorderSide(
                    color: theme.inputDecorationTheme.hintStyle?.color ??
                        theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Text(tl('Download Update')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onSkipTap,
            child: Text(tl('Skip this version')),
          ),
        ),
      ],
    );
  }
}
