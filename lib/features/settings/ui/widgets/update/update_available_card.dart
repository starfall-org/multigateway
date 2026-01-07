import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Card hiển thị thông tin cập nhật có sẵn
class UpdateAvailableCard extends StatelessWidget {
  final String latestVersion;
  final VoidCallback onSkipTap;
  final VoidCallback onDownloadTap;

  const UpdateAvailableCard({
    super.key,
    required this.latestVersion,
    required this.onSkipTap,
    required this.onDownloadTap,
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Placholder text'}: $latestVersion',
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
            const _UpdateFeatures(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkipTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context)
                                .inputDecorationTheme
                                .hintStyle
                                ?.color ??
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
                    onPressed: onDownloadTap,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context)
                                .inputDecorationTheme
                                .hintStyle
                                ?.color ??
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
}

/// Widget hiển thị danh sách tính năng mới
class _UpdateFeatures extends StatelessWidget {
  const _UpdateFeatures();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('What\'s New'),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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
}