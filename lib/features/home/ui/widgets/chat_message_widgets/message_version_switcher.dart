import 'package:flutter/material.dart';
import 'package:multigateway/core/chat/chat.dart';

/// Widget hiển thị bộ chuyển đổi phiên bản tin nhắn
class MessageVersionSwitcher extends StatelessWidget {
  final ChatMessage message;
  final Function(int)? onSwitchVersion;

  const MessageVersionSwitcher({
    super.key,
    required this.message,
    this.onSwitchVersion,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context)
              .textTheme
              .labelSmall
              ?.color
              ?.withValues(alpha: 0.6),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_left, size: 18),
          onPressed: message.currentVersionIndex > 0
              ? () => onSwitchVersion?.call(message.currentVersionIndex - 1)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '${message.currentVersionIndex + 1}/${message.versions.length}',
            style: style,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.chevron_right, size: 18),
          onPressed: message.currentVersionIndex < message.versions.length - 1
              ? () => onSwitchVersion?.call(message.currentVersionIndex + 1)
              : null,
        ),
      ],
    );
  }
}