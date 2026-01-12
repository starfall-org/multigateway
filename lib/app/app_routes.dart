import 'package:flutter/material.dart';
import 'package:multigateway/app/config/routes.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/presentation/home_page.dart';
import 'package:multigateway/features/llm/pages/providers_page.dart';
import 'package:multigateway/features/mcp/pages/mcp_servers_page.dart';
import 'package:multigateway/features/profiles/pages/profiles_page.dart';
import 'package:multigateway/features/settings/pages/about_page.dart';
import 'package:multigateway/features/settings/pages/appearance_page.dart';
import 'package:multigateway/features/settings/pages/preferences_page.dart';
import 'package:multigateway/features/settings/pages/settings_page.dart';
import 'package:multigateway/features/settings/pages/update_page.dart';
import 'package:multigateway/features/settings/pages/userdata_page.dart';
import 'package:multigateway/features/speech/pages/speech_sevices_page.dart';

/// Generate a route based on the route name.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatPage());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    case AppRoutes.appearance:
      return MaterialPageRoute(builder: (_) => const AppearancePage());
    case AppRoutes.preferences:
      return MaterialPageRoute(builder: (_) => const PreferencesPage());
    case AppRoutes.about:
      return MaterialPageRoute(builder: (_) => const AboutPage());
    case AppRoutes.update:
      return MaterialPageRoute(builder: (_) => const UpdatePage());
    case AppRoutes.userdata:
      return MaterialPageRoute(builder: (_) => const DataControlsScreen());
    case AppRoutes.providers:
      return MaterialPageRoute(builder: (_) => const AiProvidersPage());
    case AppRoutes.speech:
      return MaterialPageRoute(builder: (_) => const SpeechServicesPage());
    case AppRoutes.profiles:
      return MaterialPageRoute(builder: (_) => const ChatProfilesScreen());
    case AppRoutes.mcp:
      return MaterialPageRoute(builder: (_) => const McpServersPage());
    default:
      // Log the undefined route for debugging
      debugPrint(
        'Undefined route: ${settings.name}. Returning error screen instead of ChatPage.',
      );
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(tl('Not Found'))),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.chat,
                    (route) => false,
                  ),
                  child: Text(tl('Go to Home')),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
