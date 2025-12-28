import 'package:flutter/material.dart';
import '../../../../core/config/routes.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/data/ai_profile_store.dart';
import '../../../../core/data/chat_store.dart';
import '../../../../core/models/chat/conversation.dart';
import '../../../../shared/translate/tl.dart';
import '../../../ai/ui/profiles_page.dart';

class ConversationsDrawer extends StatefulWidget {
  final Function(String) onSessionSelected;
  final VoidCallback onNewChat;
  final VoidCallback? onAgentChanged;
  final String? selectedProviderName;
  final String? selectedModelName;
  final AIProfile? selectedProfile;

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
  ChatRepository? _chatRepository;
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
    _chatRepository = await ChatRepository.init();
    setState(() {
      _sessions = _chatRepository!.getConversations();
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
    await _chatRepository!.deleteConversation(id);
    _loadHistory();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return tl('Just now');
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return tl('${minutes}m ago');
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return tl('${hours}h ago');
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return tl('${days}d ago');
    } else {
      return tl('${dateTime.day}/${dateTime.month}/${dateTime.year}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, colorScheme),
            Expanded(
              child: _buildContent(context, theme, colorScheme),
            ),
            _buildFooter(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: tl('Search history...'),
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        _buildNewChatButton(context, theme, colorScheme),
        const SizedBox(height: 24),
        _buildRecentSection(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildNewChatButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: widget.onNewChat,
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(
          tl('New Chat'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _buildRecentSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            tl('Recent'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_filteredSessions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              tl('No history'),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          )
        else
          ..._filteredSessions.map((session) =>
              _buildHistoryItem(session, theme, colorScheme)),
      ],
    );
  }

  Widget _buildHistoryItem(
    Conversation session,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Dismissible(
      key: Key(session.id),
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
          size: 20,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteSession(session.id);
      },
      child: InkWell(
        onTap: () => widget.onSessionSelected(session.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 20,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeAgo(session.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildActiveProfileButton(context, theme, colorScheme),
          const SizedBox(height: 16),
          _buildUserProfile(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildActiveProfileButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final profileName = widget.selectedProfile?.name ?? tl('Standard Gateway');

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIProfilesScreen(),
          ),
        );
        if (result == true) {
          widget.onAgentChanged?.call();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.tertiary, colorScheme.primary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  profileName
                      .split(' ')
                      .map((word) => word.isNotEmpty ? word[0] : '')
                      .take(2)
                      .join()
                      .toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tl('Active Profile'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    profileName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.swap_horiz,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // TODO: Replace with actual user data from a user repository/service.
    final userName = tl('User');
    final userEmail = tl('user@example.com');

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.person,
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
