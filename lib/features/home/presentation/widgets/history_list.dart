import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/chat/chat.dart';
import 'package:multigateway/core/profile/profile.dart';

/// Danh sách lịch sử conversations
class HistoryList extends StatelessWidget {
  final List<Conversation> sessions;
  final Map<String, ChatProfile> profilesById;
  final ChatProfile? fallbackProfile;
  final Function(String) onSessionSelected;
  final Function(String) onDeleteSession;
  final Function(String, String) onRenameSession;

  const HistoryList({
    super.key,
    required this.sessions,
    required this.profilesById,
    this.fallbackProfile,
    required this.onSessionSelected,
    required this.onDeleteSession,
    required this.onRenameSession,
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
          ...sessions.map((session) {
            final profileName =
                profilesById[session.profileId]?.name ??
                fallbackProfile?.name ??
                tl('Standard Gateway');
            return _HistoryItem(
              session: session,
              profileName: profileName,
              onTap: () => onSessionSelected(session.id),
              onDelete: () => onDeleteSession(session.id),
              onRename: (newTitle) => onRenameSession(session.id, newTitle),
            );
          }),
      ],
    );
  }
}

/// Item trong history list
class _HistoryItem extends StatefulWidget {
  final Conversation session;
  final String profileName;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onRename;

  const _HistoryItem({
    required this.session,
    required this.profileName,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  void _showContextMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          onTap: () {
            // PopupMenuItem tự động đóng menu trước khi gọi onTap
            // Sử dụng SchedulerBinding để đảm bảo menu đã đóng hoàn toàn
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showRenameDialog(context);
              }
            });
          },
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: colorScheme.onSurface),
              const SizedBox(width: 12),
              Text(tl('Rename')),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.onDelete();
              }
            });
          },
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: colorScheme.error),
              const SizedBox(width: 12),
              Text(tl('Delete'), style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: widget.session.title,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tl('Rename conversation')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: tl('Enter new name'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              widget.onRename(value.trim());
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tl('Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                widget.onRename(newTitle);
                Navigator.of(context).pop();
              }
            },
            child: Text(tl('Rename')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: widget.onTap,
      onLongPress: () => _showContextMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _ProfileAvatar(
              name: widget.profileName,
              colorScheme: colorScheme,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.title,
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
                    _formatTimeAgo(widget.session.updatedAt),
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

class _ProfileAvatar extends StatelessWidget {
  final String name;
  final ColorScheme colorScheme;
  final double size;

  const _ProfileAvatar({
    required this.name,
    required this.colorScheme,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final display = initials.isNotEmpty ? initials : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.tertiary, colorScheme.primary],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          display,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
