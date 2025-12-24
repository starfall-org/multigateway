import 'package:flutter/material.dart';

import '../../../../core/models/ai/model.dart';
import '../../../../shared/translate/tl.dart';
import 'files_action_sheet.dart';

class UserInputArea extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  // Bổ sung: danh sách file đính kèm (đường dẫn), và callback thao tác
  final List<String> attachments;
  final VoidCallback onPickAttachments;
  final VoidCallback? onPickFromGallery;
  final void Function(int index) onRemoveAttachment;
  // Nút mở drawer chọn model
  final VoidCallback onOpenModelPicker;
  final AIModel? selectedAIModel;

  // Trạng thái sinh câu trả lời để disable input/nút gửi
  final bool isGenerating;

  // Nút mở drawer menu
  final VoidCallback? onOpenMenu;

  const UserInputArea({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.attachments = const [],
    required this.onPickAttachments,
    this.onPickFromGallery,
    required this.onRemoveAttachment,
    required this.onOpenModelPicker,
    this.selectedAIModel,
    this.isGenerating = false,
    this.onOpenMenu,
  });

  Widget _buildAttachmentChips(BuildContext context) {
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
    final canSend =
        !isGenerating &&
        ((controller.text.trim().isNotEmpty) || attachments.isNotEmpty);

    return GestureDetector(
      onTap: () {
        // Unfocus the TextField when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAttachmentChips(context),
              // Input row
              TextField(
                enabled: !isGenerating,
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: tl('Ask ${selectedAIModel?.name ?? 'AI'}'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  if (canSend) onSubmitted(controller.text);
                },
              ),
              const SizedBox(height: 8),
              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side buttons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          FilesActionSheet.show(
                            context,
                            onPickAttachments: onPickAttachments,
                            onPickFromGallery: onPickFromGallery,
                          );
                        },
                        tooltip: tl('Attach files'),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.extension,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          onOpenMenu?.call();
                        },
                        tooltip: tl('Quick Actions'),
                      ),
                    ],
                  ),
                  // Right side buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onOpenModelPicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedAIModel != null) ...[
                              if (selectedAIModel!.icon != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    selectedAIModel!.icon!,
                                    width: 20,
                                    height: 20,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.token, size: 20),
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.token, size: 20),
                                ),
                              Flexible(
                                child: Text(
                                  selectedAIModel!.name,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.token, size: 20),
                              ),
                              Text(
                                tl('Select Model'),
                                style: TextStyle(
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: canSend
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: canSend
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).iconTheme.color?.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: canSend
                              ? () => onSubmitted(controller.text)
                              : null,
                          tooltip: tl('Send'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
