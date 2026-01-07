import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Card hiển thị trạng thái cập nhật
class UpdateStatusCard extends StatelessWidget {
  final bool isChecking;
  final bool hasUpdate;
  final VoidCallback onCheckTap;

  const UpdateStatusCard({
    super.key,
    required this.isChecking,
    required this.hasUpdate,
    required this.onCheckTap,
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasUpdate ? 'Update available' : 'Up to date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hasUpdate
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
                onPressed: isChecking ? null : onCheckTap,
                icon: isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(
                  isChecking ? 'Checking...' : 'Check Now',
                ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}