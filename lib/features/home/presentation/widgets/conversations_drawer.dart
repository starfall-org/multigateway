import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/core/profile/profile.dart';
import 'package:multigateway/features/home/presentation/widgets/drawer_footer.dart';
import 'package:multigateway/features/home/presentation/widgets/drawer_header.dart'
    as drawer_widgets;
import 'package:multigateway/features/home/presentation/widgets/history_list.dart';
import 'package:multigateway/shared/widgets/app_sidebar.dart';

/// Drawer hiển thị danh sách conversations
class ConversationsDrawer extends StatefulWidget {
  final Function(String) onSessionSelected;
  final VoidCallback onNewChat;
  final VoidCallback? onAgentChanged;
  final String? selectedProviderName;
  final String? selectedModelName;
  final ChatProfile? selectedProfile;

  const ConversationsDrawer({
    super.key,
    required this.onSessionSelected,
    required this.onNewChat,
    this.onAgentChanged,
    this.selectedProviderName,
    this.selectedModelName,
    this.selectedProfile,
  });

  @override
  State<ConversationsDrawer> createState() => _ConversationsDrawerState();
}

class _ConversationsDrawerState extends State<ConversationsDrawer> {
  List<Conversation> _sessions = [];
  ConversationStorage? _chatRepository;
  final TextEditingController _searchController = TextEditingController();
  List<Conversation> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterSessions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    _chatRepository = await ConversationStorage.init();
    setState(() {
      _sessions = _chatRepository!.getItems();
      _filteredSessions = _sessions;
    });
  }

  void _filterSessions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSessions = _sessions;
      } else {
        _filteredSessions = _sessions.where((session) {
          return session.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _deleteSession(String id) async {
    await _chatRepository!.deleteItem(id);
    _loadHistory();
  }

  Future<void> _renameSession(String id, String newTitle) async {
    final session = _sessions.firstWhere((s) => s.id == id);
    final updatedSession = session.copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
    await _chatRepository!.updateItem(updatedSession);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSidebar(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          drawer_widgets.DrawerHeader(
            searchController: _searchController,
            onNewChat: widget.onNewChat,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                HistoryList(
                  sessions: _filteredSessions,
                  onSessionSelected: widget.onSessionSelected,
                  onDeleteSession: _deleteSession,
                  onRenameSession: _renameSession,
                ),
              ],
            ),
          ),
          DrawerFooter(
            selectedProfile: widget.selectedProfile,
            onAgentChanged: widget.onAgentChanged,
          ),
        ],
      ),
    );
  }
}
