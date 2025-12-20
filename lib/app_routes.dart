import 'package:flutter/material.dart';
// Use foundation.dart for debugPrint
import 'core/routes.dart';
import 'features/ai_profiles/presentation/add_profile_screen.dart';
import 'features/ai_profiles/presentation/ai_profiles_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/providers/presentation/add_provider_screen.dart';
import 'features/providers/presentation/providers_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/settings/presentation/appearance_screen.dart';
import 'features/settings/presentation/preferences_screen.dart';
import 'features/tts/presentation/tts_screen.dart';

/// Generate a route based on the route name.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case AppRoutes.aiProfiles:
      return MaterialPageRoute(builder: (_) => const AIProfilesScreen());
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
    case AppRoutes.providersAddOrEdit:
      return MaterialPageRoute(builder: (_) => const AddProviderScreen());
    case AppRoutes.aiProfilesAddOrEdit:
      return MaterialPageRoute(builder: (_) => const AddProfileScreen());
    default:
      // Log the undefined route for debugging
      debugPrint(
        'Undefined route: ${settings.name}. Returning error screen instead of ChatScreen.',
      );
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
