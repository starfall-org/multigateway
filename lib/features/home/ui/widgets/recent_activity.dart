import 'package:flutter/material.dart';

import '../../../../shared/translate/tl.dart';
import '../../../../shared/widgets/empty_state.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Recent Activity'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: const EmptyState(
              icon: Icons.history,
              message: 'No recent activity',
            ),
          ),
        ),
      ],
    );
  }
}


