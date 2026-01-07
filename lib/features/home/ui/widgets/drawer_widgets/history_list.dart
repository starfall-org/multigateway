import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/chat/chat.dart';

/// Danh sách lịch sử conversations
class HistoryList extends StatelessWidget {
  final List<Conversation> sessions;
  final Function(String) onSessionSelected;
  final Function(String) onDeleteSession;

  const HistoryList({
    super.key,
    required this.sessions,
    required this.onSessionSelected,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        if (sessions.isEmpty)
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
          ...sessions.map(
            (session) => _HistoryItem(
              session: session,
              onTap: () => onSessionSelected(session.id),
              onDelete: () => onDeleteSession(session.id),
            ),
          ),
      ],
    );
  }
}

/// Item trong history list
class _HistoryItem extends StatelessWidget {
  final Conversation session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(session.id),
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: colorScheme.onError, size: 20),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      child: InkWell(
        onTap: onTap,
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
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
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
}