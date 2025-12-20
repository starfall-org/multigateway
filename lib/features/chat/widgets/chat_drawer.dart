import 'package:flutter/material.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/routes.dart';
import '../../ai_profiles/presentation/ai_profiles_screen.dart';
import '../../../core/storage/chat_repository.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatDrawer extends StatefulWidget {
  final Function(String) onSessionSelected;
  final VoidCallback onNewChat;
  final VoidCallback? onAgentChanged;

  const ChatDrawer({
    super.key,
    required this.onSessionSelected,
    required this.onNewChat,
    this.onAgentChanged,
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  List<Conversation> _sessions = [];
  ChatRepository? _chatRepository;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _chatRepository = await ChatRepository.init();
    setState(() {
      _sessions = _chatRepository!.getConversations();
    });
  }

  Future<void> _deleteSession(String id) async {
    await _chatRepository!.deleteConversation(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(
                        context,
                      ).iconTheme.color?.withValues(alpha: 0.7),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'app_title'.tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'drawer.new_chat'.tr(),
                    onPressed: widget.onNewChat,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      'drawer.recent'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  if (_sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'drawer.no_history'.tr(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ..._sessions.map((session) => _buildHistoryItem(session)),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    Icons.help_outline,
                    'drawer.help_activity'.tr(),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.settings_outlined,
                    'drawer.settings'.tr(),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.swap_horiz_outlined,
                    'drawer.change_agent'.tr(),
                    onTap: () async {
                      Navigator.pop(context); // Close drawer
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIProfilesScreen(),
                        ),
                      );
                      if (result == true && widget.onAgentChanged != null) {
                        widget.onAgentChanged!();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Conversation session) {
    return Dismissible(
      key: Key(session.id),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
          size: 20,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteSession(session.id);
      },
      child: ListTile(
        leading: Icon(
          Icons.chat_bubble_outline,
          size: 20,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () => widget.onSessionSelected(session.id),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
