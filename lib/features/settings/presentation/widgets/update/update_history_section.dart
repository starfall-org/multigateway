import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/settings/presentation/controllers/update_controller.dart';

/// Section hiển thị lịch sử cập nhật
class UpdateHistorySection extends StatelessWidget {
  final List<ReleaseInfo> releases;
  final bool isLoading;

  const UpdateHistorySection({
    super.key,
    required this.releases,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Update History'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (releases.isEmpty)
          Card(
            child: _HistoryItem(
              version: tl('No releases found'),
              date: '',
              features: const [],
            ),
          )
        else
          ...releases.map(
            (release) => Card(
              child: _HistoryItem(
                version: release.version,
                date: _formatDate(release.publishedAt),
                features: release.highlights,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget hiển thị một item lịch sử
class _HistoryItem extends StatelessWidget {
  final String version;
  final String date;
  final List<String> features;

  const _HistoryItem({
    required this.version,
    required this.date,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final versionLabel = version.contains(' ') ? version : 'v$version';
    final displayFeatures =
        features.isEmpty ? <String>[tl('No release notes provided')] : features;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                versionLabel,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                date.isEmpty ? tl('Unknown date') : date,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...displayFeatures.map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: theme.colorScheme.primary,
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
}

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return tl('Unknown date');
  final local = dateTime.toLocal();
  return local.toIso8601String().split('T').first;
}
