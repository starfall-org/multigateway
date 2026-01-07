import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Widget hiển thị dropdown cho reasoning content
class ReasoningDropdown extends StatelessWidget {
  final String reasoning;

  const ReasoningDropdown({
    super.key,
    required this.reasoning,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withValues(alpha: 0.8),
        );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8),
        collapsedIconColor: Theme.of(context).iconTheme.color,
        iconColor: Theme.of(context).iconTheme.color,
        title: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 4),
            Text(tl('Reasoning content'), style: style),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(reasoning, style: style),
          ),
        ],
      ),
    );
  }
}