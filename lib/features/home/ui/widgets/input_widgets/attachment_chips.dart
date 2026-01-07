import 'package:flutter/material.dart';

/// Widget hiển thị danh sách file attachments dưới dạng chips
class AttachmentChips extends StatelessWidget {
  final List<String> attachments;
  final Function(int index) onRemove;

  const AttachmentChips({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: -8,
        children: List.generate(attachments.length, (i) {
          final name = attachments[i].split('/').last;
          return Chip(
            label: Text(name, overflow: TextOverflow.ellipsis),
            onDeleted: () => onRemove(i),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }),
      ),
    );
  }
}