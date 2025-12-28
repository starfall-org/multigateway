import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/models/ai_model/base.dart';
import '../../../../shared/translate/tl.dart';
import 'files_action_sheet.dart';

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

  @override
  State<UserInputArea> createState() => _UserInputAreaState();
}

class _UserInputAreaState extends State<UserInputArea> {
  late FocusNode _focusNode;
  bool _isFocused = false;

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
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _unfocusTextField() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      // Ẩn bàn phím ảo bằng cách sử dụng SystemChannels
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  Widget _buildAttachmentChips(BuildContext context) {
    if (widget.attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: -8,
        children: List.generate(widget.attachments.length, (i) {
          final name = widget.attachments[i].split('/').last;
          return Chip(
            label: Text(name, overflow: TextOverflow.ellipsis),
            onDeleted: () => widget.onRemoveAttachment(i),
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
        !widget.isGenerating &&
        ((widget.controller.text.trim().isNotEmpty) ||
            widget.attachments.isNotEmpty);

    return GestureDetector(
      onTapDown: (_) {
        // Unfocus the TextField when tapping outside và ẩn bàn phím
        _unfocusTextField();
      },
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      child: Container(
        width: double.infinity,
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
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    // Thêm suffix để hiển thị trạng thái focus
                    suffixIcon: _isFocused
                        ? IconButton(
                            icon: const Icon(Icons.keyboard_hide),
                            onPressed: _unfocusTextField,
                            tooltip: tl('Hide keyboard'),
                          )
                        : null,
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
                  // Right side buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Unfocus trước khi mở model picker
                          _unfocusTextField();
                          widget.onOpenModelPicker();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.selectedAIModel != null) ...[
                              if (widget.selectedAIModel!.icon != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: _buildThemeAwareImageForUserInput(
                                    context,
                                    Image.asset(
                                      widget.selectedAIModel!.icon!,
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
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.token, size: 20),
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTapDown: (_) {},
                        child: Container(
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
                              Icons.arrow_upward,
                              color: canSend
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).iconTheme.color?.withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: canSend
                                ? () {
                                    widget.onSubmitted(widget.controller.text);
                                    // Unfocus sau khi gửi
                                    _unfocusTextField();
                                  }
                                : null,
                            tooltip: tl('Send'),
                          ),
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
