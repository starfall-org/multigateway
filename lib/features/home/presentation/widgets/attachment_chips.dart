import 'dart:io';

import 'package:flutter/material.dart';

/// Widget hiển thị danh sách file attachments dưới dạng ô vuông với thumbnail
class AttachmentChips extends StatelessWidget {
  final List<String> attachments;
  final Function(int index) onRemove;

  const AttachmentChips({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  bool _isImage(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  IconData _getFileIcon(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: attachments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final path = attachments[i];
          final isImage = _isImage(path);

          return Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        _getFileIcon(path),
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () => onRemove(i),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
