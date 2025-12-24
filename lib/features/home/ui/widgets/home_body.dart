import 'package:flutter/material.dart';

import 'welcome_card.dart';
import 'quick_actions.dart';
import 'recent_activity.dart';

/// Main body content widget
class HomeBody extends StatelessWidget {
  const HomeBody({
    super.key,
    required this.onNavigateToChat,
    required this.onNavigateToAIProfiles,
    required this.onNavigateToProviders,
    required this.onNavigateToMCPServers,
    required this.onNavigateToSpeechServices,
  });

  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToAIProfiles;
  final VoidCallback onNavigateToProviders;
  final VoidCallback onNavigateToMCPServers;
  final VoidCallback onNavigateToSpeechServices;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeCard(onNavigateToChat: onNavigateToChat),
          const SizedBox(height: 24),
          QuickActions(
            onNavigateToAIProfiles: onNavigateToAIProfiles,
            onNavigateToProviders: onNavigateToProviders,
            onNavigateToMCPServers: onNavigateToMCPServers,
            onNavigateToSpeechServices: onNavigateToSpeechServices,
          ),
          const SizedBox(height: 24),
          const RecentActivity(),
        ],
      ),
    );
  }
}


