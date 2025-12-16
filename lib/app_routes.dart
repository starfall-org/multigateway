import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'features/agents/views/agent_list_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/providers/views/providers_screen.dart';
import 'features/settings/views/settings_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case AppRoutes.agents:
      return MaterialPageRoute(builder: (_) => const AgentListScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.providers:
      return MaterialPageRoute(builder: (_) => const ProvidersScreen());
    default:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
  }
}
