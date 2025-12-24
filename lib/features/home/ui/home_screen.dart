import 'package:flutter/material.dart';

import '../../../core/config/routes.dart';
import '../../../shared/translate/tl.dart';
import '../../ai/ui/profiles_page.dart';
import '../../settings/ui/settings_page.dart';
import 'chat_screen.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_body.dart';

/// Màn hình chủ hiển thị dashboard chính của ứng dụng
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tl('Home'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              tl('Main Dashboard'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: () => _navigateToSettings(),
          ),
        ],
      ),
      drawer: HomeDrawer(
        onNavigateToChat: _navigateToChat,
        onNavigateToAIProfiles: _navigateToAIProfiles,
        onNavigateToProviders: _navigateToProviders,
        onNavigateToMCPServers: _navigateToMCPServers,
        onNavigateToSpeechServices: _navigateToSpeechServices,
        onNavigateToSettings: _navigateToSettings,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: HomeBody(
          onNavigateToChat: _navigateToChat,
          onNavigateToAIProfiles: _navigateToAIProfiles,
          onNavigateToProviders: _navigateToProviders,
          onNavigateToMCPServers: _navigateToMCPServers,
          onNavigateToSpeechServices: _navigateToSpeechServices,
        ),
      ),
    );
  }

  /// Navigation methods
  void _navigateToChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  void _navigateToAIProfiles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIProfilesScreen()),
    );
  }

  void _navigateToProviders() {
    Navigator.pushNamed(context, AppRoutes.aiProviders);
  }

  void _navigateToMCPServers() {
    Navigator.pushNamed(context, AppRoutes.mcpServers);
  }

  void _navigateToSpeechServices() {
    Navigator.pushNamed(context, AppRoutes.aiSpeechServices);
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}
