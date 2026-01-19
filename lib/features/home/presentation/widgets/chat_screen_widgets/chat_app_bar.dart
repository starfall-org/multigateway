import 'package:flutter/material.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/presentation/widgets/chat_screen_widgets/agent_avatar_button.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenEndDrawer;

  const ChatAppBar({
    super.key,
    required this.onOpenDrawer,
    required this.onOpenEndDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = ChatControllerProvider.of(context);

    return Watch((context) {
      final currentSession = ctrl.session.currentSession.value;
      final selectedProfile = ctrl.profile.selectedProfile.value;

      return AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
          ),
          onPressed: onOpenDrawer,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentSession?.title ?? 'New Chat',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              selectedProfile?.name ?? 'No Profile',
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
          AgentAvatarButton(
            profileName: selectedProfile?.name,
            onTap: onOpenEndDrawer,
          ),
        ],
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
