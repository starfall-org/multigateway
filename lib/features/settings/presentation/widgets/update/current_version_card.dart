import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Card hiển thị phiên bản hiện tại
class CurrentVersionCard extends StatelessWidget {
  final String version;
  final DateTime? lastCheckedAt;

  const CurrentVersionCard({
    super.key,
    required this.version,
    this.lastCheckedAt,
  });

  @override
  Widget build(BuildContext context) {
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
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
            _VersionInfo(label: 'Version Number', value: version),
            const SizedBox(height: 8),
            _VersionInfo(
              label: 'Last Checked',
              value: lastCheckedAt != null
                  ? _formatDate(lastCheckedAt!)
                  : tl('Not checked yet'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị thông tin phiên bản
class _VersionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _VersionInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
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
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final formatted = local.toIso8601String();
  final withoutMillis = formatted.split('.').first;
  return withoutMillis.replaceFirst('T', ' ');
}
