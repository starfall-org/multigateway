import 'package:flutter/material.dart';
import 'package:lmhub/src/features/agents/presentation/agent_list_screen.dart';
import 'package:lmhub/src/features/settings/presentation/settings_screen.dart';
import 'package:lmhub/src/core/storage/chat_repository.dart';
import 'package:lmhub/src/features/chat/domain/chat_models.dart';

class ChatDrawer extends StatefulWidget {
  final Function(String) onSessionSelected;
  final VoidCallback onNewChat;

  const ChatDrawer({
    super.key,
    required this.onSessionSelected,
    required this.onNewChat,
  });

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  List<ChatSession> _sessions = [];
  ChatRepository? _chatRepository;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _chatRepository = await ChatRepository.init();
    setState(() {
      _sessions = _chatRepository!.getSessions();
    });
  }

  Future<void> _deleteSession(String id) async {
    await _chatRepository!.deleteSession(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF0F4F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black54),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LMHub',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  tooltip: 'New Chat',
                  onPressed: widget.onNewChat,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Gần đây',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (_sessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'No history',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ..._sessions.map((session) => _buildHistoryItem(session)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  Icons.help_outline,
                  'Trợ giúp & hoạt động',
                ),
                _buildDrawerItem(
                  context,
                  Icons.settings_outlined,
                  'Cài đặt',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  Icons.swap_horiz_outlined,
                  'Change Agent',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatSession session) {
    return Dismissible(
      key: Key(session.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteSession(session.id);
      },
      child: ListTile(
        leading: const Icon(
          Icons.chat_bubble_outline,
          size: 20,
          color: Colors.black54,
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
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
