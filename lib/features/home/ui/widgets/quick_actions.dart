import 'package:flutter/material.dart';

import '../../../../shared/translate/tl.dart';
import 'action_card.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onNavigateToAIProfiles,
    required this.onNavigateToProviders,
    required this.onNavigateToMCPServers,
    required this.onNavigateToSpeechServices,
  });

  final VoidCallback onNavigateToAIProfiles;
  final VoidCallback onNavigateToProviders;
  final VoidCallback onNavigateToMCPServers;
  final VoidCallback onNavigateToSpeechServices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Quick Actions'),
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            ActionCard(
              icon: Icons.person_outline,
              title: 'AI Profiles',
              onTap: onNavigateToAIProfiles,
            ),
            ActionCard(
              icon: Icons.cloud_outlined,
              title: 'Providers',
              onTap: onNavigateToProviders,
            ),
            ActionCard(
              icon: Icons.extension_outlined,
              title: 'MCP Servers',
              onTap: onNavigateToMCPServers,
            ),
            ActionCard(
              icon: Icons.record_voice_over,
              title: 'Speech Services',
              onTap: onNavigateToSpeechServices,
            ),
          ],
        ),
      ],
    );
  }
}


