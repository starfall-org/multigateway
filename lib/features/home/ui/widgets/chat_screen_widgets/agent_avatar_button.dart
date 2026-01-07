import 'package:flutter/material.dart';

/// Widget hiển thị avatar của agent trong AppBar
class AgentAvatarButton extends StatelessWidget {
  final String? profileName;
  final VoidCallback onTap;

  const AgentAvatarButton({
    super.key,
    required this.profileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (profileName?.isNotEmpty == true ? profileName![0] : 'A')
        .toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.1),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}