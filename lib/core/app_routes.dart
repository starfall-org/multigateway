import 'package:flutter/material.dart';
// Use foundation.dart for debugPrint
import '../features/ai/ui/add_profile_screen.dart';
import '../features/ai/ui/ai_profiles_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/ai/ui/sub/add_provider_screen.dart';
import '../features/ai/ui/providers_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/appearance_screen.dart';
import '../features/settings/presentation/preferences_screen.dart';
import '../features/chat/speech_sevice_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/settings/datacontrols/presentation/datacontrols_screen.dart';
import '../features/settings/about/presentation/about_screen.dart';
import '../features/update/presentation/update_screen.dart';
import '../shared/translate/tl.dart';
import 'config/routes.dart';

/// Generate a route based on the route name.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case AppRoutes.aiProfiles:
      return MaterialPageRoute(builder: (_) => const AIProfilesScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    case AppRoutes.providers:
      return MaterialPageRoute(builder: (_) => const ProvidersScreen());
    case AppRoutes.appearance:
      return MaterialPageRoute(builder: (_) => const AppearanceSettingcreen());
    case AppRoutes.tts:
      return MaterialPageRoute(builder: (_) => const TTSScreen());
    case AppRoutes.preferences:
      return MaterialPageRoute(builder: (_) => const PreferencesScreen());
    case AppRoutes.datacontrols:
      return MaterialPageRoute(builder: (_) => const DataControlsScreen());
    case AppRoutes.about:
      return MaterialPageRoute(builder: (_) => const AboutScreen());
    case AppRoutes.update:
      return MaterialPageRoute(builder: (_) => const UpdateScreen());
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
          appBar: AppBar(title: Text(tl('Route Not Found'))),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tl('Route not found:')),
                Text(settings.name ?? 'Unknown route'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.chat,
                    (route) => false,
                  ),
                  child: Text(tl('Go to Chat')),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
