import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Button để tạo chat mới
class NewChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewChatButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(
          tl('New Chat'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
}