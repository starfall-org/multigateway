import 'package:flutter/material.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/data/chat_store.dart';
import '../../../../core/models/chat/conversation.dart';
import '../../../../shared/translate/tl.dart';
import '../../../../shared/utils/icon_builder.dart';
import '../../../ai/ui/profiles_page.dart';

class ConversationsDrawer extends StatefulWidget {
  final Function(String) onSessionSelected;
  final VoidCallback onNewChat;
  final VoidCallback? onAgentChanged;
  final String? selectedProviderName;
  final String? selectedModelName;

  const ConversationsDrawer({
    super.key,
    required this.onSessionSelected,
    required this.onNewChat,
    this.onAgentChanged,
    this.selectedProviderName,
    this.selectedModelName,
  });

  @override
  State<ConversationsDrawer> createState() => _ConversationsDrawerState();
}

class _ConversationsDrawerState extends State<ConversationsDrawer> {
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
                    tl('AI Gateway'),
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
                    tooltip: tl('New Chat'),
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
                      tl('Recent'),
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
                        tl('No history'),
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
                    'Help & Activity',
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.swap_horiz_outlined,
                    'Change AI Profile',
                    onTap: () async {
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
        child: SizedBox(width: 24, height: 24, child: _buildModelIcon()),
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

  Widget _buildModelIcon() {
    if (widget.selectedProviderName != null &&
        widget.selectedModelName != null) {
      return buildIcon(widget.selectedModelName!);
    }
    return Icon(
      Icons.delete,
      color: Theme.of(context).colorScheme.onError,
      size: 20,
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
