import 'package:flutter/material.dart';
import 'package:multigateway/features/home/ui/widgets/chat_controller_provider.dart';
import 'package:multigateway/features/home/ui/widgets/chat_screen_widgets/agent_avatar_button.dart';

/// AppBar cho chat screen
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
    final controller = ChatControllerProvider.of(context);

    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.history,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
        ),
        onPressed: onOpenDrawer,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.currentSession?.title ?? 'New Chat',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            controller.selectedModelName ?? '',
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
          profileName: controller.selectedProfile?.name,
          onTap: onOpenEndDrawer,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}