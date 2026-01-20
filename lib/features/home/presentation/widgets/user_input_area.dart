import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/home/presentation/widgets/attachment_chips.dart';
import 'package:multigateway/features/home/presentation/widgets/files_action_sheet.dart';
import 'package:multigateway/shared/utils/icon_builder.dart';

class UserInputArea extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  // Bổ sung: danh sách file đính kèm (đường dẫn), và callback thao tác
  final List<String> attachments;
  final VoidCallback onPickAttachments;
  final VoidCallback? onPickFromGallery;
  final void Function(int index) onRemoveAttachment;
  // Nút mở drawer chọn model
  final VoidCallback onOpenModelPicker;
  final LlmModel? selectedLlmModel;

  // Trạng thái sinh câu trả lời để disable input/nút gửi
  final bool isGenerating;
  final VoidCallback? onStopGeneration;

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
    this.selectedLlmModel,
    this.isGenerating = false,
    this.onStopGeneration,
    this.onOpenMenu,
  });

  @override
  State<UserInputArea> createState() => _UserInputAreaState();
}

class _UserInputAreaState extends State<UserInputArea> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    // Listen to controller changes to update button state
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _unfocusTextField() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        !widget.isGenerating &&
        ((widget.controller.text.trim().isNotEmpty) ||
            widget.attachments.isNotEmpty);
    final showStop = widget.isGenerating;
    final stopEnabled = widget.onStopGeneration != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AttachmentChips(
                attachments: widget.attachments,
                onRemove: widget.onRemoveAttachment,
              ),
              // Input row với focus management
              GestureDetector(
                onTap: () {
                  // Chỉ focus khi người dùng thực sự tap vào TextField
                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                },
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: widget.controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  // Ngăn auto-focus khi widget được build lại
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: tl('Type something...'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    // Đưa nút gửi lên đây thay cho nút ẩn bàn phím
                    suffixIcon: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: showStop
                          ? (stopEnabled ? widget.onStopGeneration : null)
                          : canSend
                          ? () {
                              widget.onSubmitted(widget.controller.text);
                              _unfocusTextField();
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: showStop
                              ? Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.12)
                              : canSend
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1)
                              : Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            showStop ? Icons.stop : Icons.arrow_upward,
                            color: showStop
                                ? Theme.of(context).colorScheme.error
                                : canSend
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).iconTheme.color?.withValues(alpha: 0.5),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onSubmitted: (_) {
                    if (canSend) {
                      widget.onSubmitted(widget.controller.text);
                      // Unfocus sau khi gửi tin nhắn
                      _unfocusTextField();
                    }
                  },
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  // Ngăn tự động hiển thị keyboard khi không cần thiết
                  enableInteractiveSelection: true,
                ),
              ),
              const SizedBox(height: 4),
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
                          // Unfocus trước khi mở action sheet
                          _unfocusTextField();
                          FilesActionSheet.show(
                            context,
                            onPickAttachments: widget.onPickAttachments,
                            onPickFromGallery: widget.onPickFromGallery,
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
                          // Unfocus trước khi mở menu
                          _unfocusTextField();
                          widget.onOpenMenu?.call();
                        },
                        tooltip: tl('Quick Actions'),
                      ),
                    ],
                  ),
                  // Right side: Nút chọn model dạng outlined, không nền đặc
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          _unfocusTextField();
                          widget.onOpenModelPicker();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ModelIcon(model: widget.selectedLlmModel),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.selectedLlmModel?.displayName ??
                                    tl('Select Model'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _ModelIcon extends StatelessWidget {
  final LlmModel? model;
  const _ModelIcon({this.model});

  @override
  Widget build(BuildContext context) {
    if (model != null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: model!.icon != null
            ? buildIcon(model!.icon!)
            : buildIcon(model!.id),
      );
    }
    return const Icon(Icons.token, size: 20);
  }
}
