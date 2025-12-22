import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../chat/chat_screen.dart';
import '../../ai/ui/ai_profiles_screen.dart';
import '../../ai/ui/providers_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../chat/speech_sevice_screen.dart';

import '../../../core/translate.dart';

/// Màn hình chủ hiển thị dashboard chính của ứng dụng
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      drawer: _buildDrawer(),
      body: SafeArea(
        top: false,
        bottom: true,
        child: _buildBody(),
      ),
    );
  }

  /// Xây dựng drawer menu
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        top: true,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('AI Gateway'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tl('App Navigation'),
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.chat_bubble_outline,
              title: 'Chat',
              onTap: () => _navigateToChat(),
            ),
            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'AI Profiles',
              onTap: () => _navigateToAIProfiles(),
            ),
            _buildDrawerItem(
              icon: Icons.cloud_outlined,
              title: 'Providers',
              onTap: () => _navigateToProviders(),
            ),
            _buildDrawerItem(
              icon: Icons.extension_outlined,
              title: 'MCP Servers',
              onTap: () => _navigateToMCP(),
            ),
            _buildDrawerItem(
              icon: Icons.record_voice_over,
              title: 'Speech Services',
              onTap: () => _navigateToTTS(),
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => _navigateToSettings(),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng item trong drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  /// Xây dựng nội dung chính của màn hình
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  /// Xây dựng card chào mừng
  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.waving_hand,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tl('Welcome to AI Gateway'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tl('Comprehensive AI chat platform'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _navigateToChat(),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text(tl('Start Chatting')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng các hành động nhanh
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Quick Actions'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
            _buildActionCard(
              icon: Icons.person_outline,
              title: 'AI Profiles',
              onTap: () => _navigateToAIProfiles(),
            ),
            _buildActionCard(
              icon: Icons.cloud_outlined,
              title: 'Providers',
              onTap: () => _navigateToProviders(),
            ),
            _buildActionCard(
              icon: Icons.extension_outlined,
              title: 'MCP Servers',
              onTap: () => _navigateToMCP(),
            ),
            _buildActionCard(
              icon: Icons.record_voice_over,
              title: 'Speech Services',
              onTap: () => _navigateToTTS(),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng card hành động
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng phần hoạt động gần đây
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tl('Recent Activity'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: EmptyState(
              icon: Icons.history,
              message: 'No recent activity',
            ),
          ),
        ),
      ],
    );
  }

  /// Navigation methods
  void _navigateToChat() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  void _navigateToAIProfiles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIProfilesScreen()),
    );
  }

  void _navigateToProviders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProvidersScreen()),
    );
  }

  void _navigateToMCP() {
    // TODO: Implement MCP navigation when MCPScreen is created
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tl('MCP feature coming soon'))));
  }

  void _navigateToTTS() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TTSScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
