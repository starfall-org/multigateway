import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  // Bổ sung: danh sách file đính kèm (đường dẫn), và callback thao tác
  final List<String> attachments;
  final VoidCallback onPickAttachments;
  final void Function(int index) onRemoveAttachment;

  // Trạng thái sinh câu trả lời để disable input/nút gửi
  final bool isGenerating;

  // Tuỳ chọn: hành động cho nút mic (ví dụ TTS)
  final VoidCallback? onMicTap;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.attachments = const [],
    required this.onPickAttachments,
    required this.onRemoveAttachment,
    this.isGenerating = false,
    this.onMicTap,
  });

  Widget _buildAttachmentChips(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: -8,
        children: List.generate(attachments.length, (i) {
          final name = attachments[i].split('/').last;
          return Chip(
            label: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () => onRemoveAttachment(i),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !isGenerating &&
        ((controller.text.trim().isNotEmpty) || attachments.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, top: 8, bottom: 4),
              child: Text(
                'input.ask'.tr(),
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            _buildAttachmentChips(context),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.black87,
                  ),
                  onPressed: onPickAttachments,
                  tooltip: 'input.attach_files'.tr(),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.image_outlined, color: Colors.black87),
                  onPressed: onPickAttachments,
                  tooltip: 'input.pick_images'.tr(),
                ),
                Expanded(
                  child: TextField(
                    enabled: !isGenerating,
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'input.placeholder'.tr(),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) {
                      if (canSend) onSubmitted(controller.text);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none, color: Colors.black87),
                  onPressed: onMicTap,
                  tooltip: 'input.mic_tts'.tr(),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: canSend ? const Color(0xFFE8F0FE) : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: canSend ? Colors.blue : Colors.grey[500],
                      size: 20,
                    ),
                    onPressed:
                        canSend ? () => onSubmitted(controller.text) : null,
                    tooltip: 'input.send'.tr(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
