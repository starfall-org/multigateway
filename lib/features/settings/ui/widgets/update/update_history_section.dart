import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Section hiển thị lịch sử cập nhật
class UpdateHistorySection extends StatelessWidget {
  const UpdateHistorySection({super.key});

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
        Card(
          child: _HistoryItem(
            version: '0.0.0',
            date: DateTime.now().toString(),
            features: const [
              'No update history',
              "This feature will be added in the future",
            ],
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tl('v$version'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
}