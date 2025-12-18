import 'package:flutter/material.dart';
// Use foundation.dart for debugPrint
import 'core/routes.dart';
import 'features/agents/presentation/agent_list_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/providers/presentation/providers_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/appearance_screen.dart';
import 'features/settings/presentation/preferences_screen.dart';
import 'features/tts/views/tts_screen.dart';

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
    case AppRoutes.appearance:
      return MaterialPageRoute(builder: (_) => const AppearanceScreen());
    case AppRoutes.tts:
      return MaterialPageRoute(builder: (_) => const TTSScreen());
    case AppRoutes.preferences:
      return MaterialPageRoute(builder: (_) => const PreferencesScreen());
    default:
      // Log the undefined route for debugging
      debugPrint('Undefined route: ${settings.name}. Returning error screen instead of ChatScreen.');
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Route Not Found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Route not found:'),
                Text(settings.name ?? 'Unknown route'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.chat,
                    (route) => false,
                  ),
                  child: const Text('Go to Chat'),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
