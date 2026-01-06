import 'package:flutter/material.dart';
import 'package:multigateway/app/config/routes.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/ui/widgets/menu_item_tile.dart';
import 'package:multigateway/shared/widgets/app_sidebar.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return AppSidebar(
      position: SidebarPosition.right,
      width: screenWidth,
      backgroundColor: colorScheme.surface,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Menu',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'AI Features'),
                    const SizedBox(height: 8),
                    MenuItemTile(
                      icon: Icons.psychology_outlined,
                      title: tl('Profiles'),
                      route: AppRoutes.profiles,
                    ),
                    MenuItemTile(
                      icon: Icons.cloud_outlined,
                      title: tl('Providers'),

                      route: AppRoutes.providers,
                    ),
                    MenuItemTile(
                      icon: Icons.dns_outlined,
                      title: tl('MCP Servers'),

                      route: AppRoutes.mcp,
                    ),
                    MenuItemTile(
                      icon: Icons.record_voice_over_outlined,
                      title: tl('Speech Services'),

                      route: AppRoutes.speech,
                    ),
                    MenuItemTile(
                      icon: Icons.settings_outlined,
                      title: tl('Settings'),
                      route: AppRoutes.settings,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
