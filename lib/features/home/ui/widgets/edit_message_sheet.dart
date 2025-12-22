import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/widgets/dialog.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'dart:io';

import '../../../core/translate.dart';

class EditMessageResult {
  final String content;
  final List<String> attachments;
  final bool resend;

  const EditMessageResult({
    required this.content,
    required this.attachments,
    required this.resend,
  });
}

class EditMessageDialog extends StatefulWidget {
  final String initialContent;
  final List<String> initialAttachments;

  const EditMessageDialog({
    super.key,
    required this.initialContent,
    required this.initialAttachments,
  });

  static Future<EditMessageResult?> show(
    BuildContext context, {
    required String initialContent,
    required List<String> initialAttachments,
  }) {
    return showDialog<EditMessageResult?>(
      context: context,
      builder: (ctx) => EditMessageDialog(
        initialContent: initialContent,
        initialAttachments: initialAttachments,
      ),
    );
  }

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late final TextEditingController _controller;
  late final List<String> _attachments;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
    _attachments = List<String>.from(widget.initialAttachments);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        // Cho phép mọi loại file để phù hợp chức năng "thêm/xóa attachments"
        type: FileType.any,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;
      setState(() {
        for (final p in paths) {
          if (!_attachments.contains(p)) _attachments.add(p);
        }
      });
    } catch (_) {}
  }

  void _removeAt(int index) {
    if (index < 0 || index >= _attachments.length) return;
    setState(() {
      _attachments.removeAt(index);
    });
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  Widget _attachmentTile(String path) {
    final isImg = _isImagePath(path);
    const double size = 84;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: isImg
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _fallbackTile(path),
                  )
                : _fallbackTile(path),
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final idx = _attachments.indexOf(path);
                if (idx != -1) _removeAt(idx);
              },
              customBorder: const CircleBorder(),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withAlpha(40),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackTile(String path) {
    final name = path.split('/').last;
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  void _return(bool resend) {
    Navigator.of(context).pop(
      EditMessageResult(
        content: _controller.text,
        attachments: List<String>.from(_attachments),
        resend: resend,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppDialog(
      title: Text(tl('Edit Message')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _controller,
              label: 'Message',
              minLines: 3,
              maxLines: 10,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${'Attachments'} (${_attachments.length})',
                  style: theme.textTheme.labelLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickAttachments,
                  icon: const Icon(Icons.attach_file),
                  label: Text(tl('Add')),
                ),
              ],
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _attachments.map(_attachmentTile).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(tl('Cancel')),
        ),
        FilledButton.tonal(
          onPressed: () => _return(false),
          child: Text(tl('Save')),
        ),
        FilledButton(
          onPressed: () => _return(true),
          child: Text(tl('dialog.save_and_resend')),
        ),
      ],
    );
  }
}
