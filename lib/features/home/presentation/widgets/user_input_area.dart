import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/core/llm/models/llm_provider_models.dart';
import 'package:multigateway/features/home/presentation/widgets/files_action_sheet.dart';
import 'package:multigateway/features/home/presentation/widgets/input_widgets/attachment_chips.dart';

/// Helper để tạo theme-aware image
Widget _buildThemeAwareImageForUserInput(BuildContext context, Widget child) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      BlendMode.overlay,
    ),
    child: child,
  );
}

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
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _unfocusTextField() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      // Ẩn bàn phím ảo bằng cách sử dụng SystemChannels
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend =
        !widget.isGenerating &&
        ((widget.controller.text.trim().isNotEmpty) ||
            widget.attachments.isNotEmpty);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 4 + bottomPadding),
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
                enabled: !widget.isGenerating,
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
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Đưa nút gửi lên đây thay cho nút ẩn bàn phím
                  suffixIcon: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: canSend
                        ? () {
                            widget.onSubmitted(widget.controller.text);
                            _unfocusTextField();
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(4),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_upward,
                          color: canSend
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
                // Right side: Nút chọn model kéo dài với tên model
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _unfocusTextField();
                        widget.onOpenModelPicker();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.selectedLlmModel != null) ...[
                            if (widget.selectedLlmModel!.icon != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildThemeAwareImageForUserInput(
                                  context,
                                  Image.asset(
                                    widget.selectedLlmModel!.icon!,
                                    width: 20,
                                    height: 20,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.token, size: 20),
                                  ),
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.token, size: 20),
                              ),
                            Flexible(
                              child: Text(
                                widget.selectedLlmModel!.displayName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ] else ...[
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.token, size: 20),
                            ),
                            Text(tl('Select Model')),
                          ],
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
    );
  }
}
