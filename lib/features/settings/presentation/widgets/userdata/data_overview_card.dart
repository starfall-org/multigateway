import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Card hiển thị tổng quan dữ liệu
class DataOverviewCard extends StatelessWidget {
  final int conversationCount;
  final int profileCount;
  final int providerCount;

  const DataOverviewCard({
    super.key,
    required this.conversationCount,
    required this.profileCount,
    required this.providerCount,
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.chat_bubble,
                  label: tl('Conversations'),
                  value: '$conversationCount',
                ),
                _StatItem(
                  icon: Icons.person,
                  label: tl('Profiles'),
                  value: '$profileCount',
                ),
                _StatItem(
                  icon: Icons.cloud,
                  label: tl('Providers'),
                  value: '$providerCount',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị item thống kê
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}
