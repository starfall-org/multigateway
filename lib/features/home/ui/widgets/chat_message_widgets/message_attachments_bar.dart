import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multigateway/shared/utils/theme_aware_image.dart';

/// Widget hiển thị thanh đính kèm tệp trong tin nhắn
class MessageAttachmentsBar extends StatelessWidget {
  final List<String> attachments;
  final Function(List<String>)? onOpenAttachments;

  const MessageAttachmentsBar({
    super.key,
    required this.attachments,
    this.onOpenAttachments,
  });

  @override
  Widget build(BuildContext context) {
    final count = attachments.length;
    final showOverflow = count > 4;
    final visible = showOverflow ? attachments.take(3).toList() : attachments;
    final tileSize = _computeTileSize(count);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showOverflow)
          _OverflowTile(
            attachments: attachments,
            size: tileSize,
            onTap: () => onOpenAttachments?.call(attachments),
          ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visible
                  .map((path) => _AttachmentTile(
                        path: path,
                        size: tileSize,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  double _computeTileSize(int count) {
    if (count <= 1) return 220;
    if (count == 2) return 140;
    if (count == 3) return 110;
    return 96;
  }
}

/// Widget hiển thị nút "xem thêm" khi có nhiều tệp đính kèm
class _OverflowTile extends StatelessWidget {
  final List<String> attachments;
  final double size;
  final VoidCallback? onTap;

  const _OverflowTile({
    required this.attachments,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(80),
              width: 1,
            ),
          ),
          child: const Center(child: Icon(Icons.more_horiz)),
        ),
      ),
    );
  }
}

/// Widget hiển thị một tệp đính kèm
class _AttachmentTile extends StatelessWidget {
  final String path;
  final double size;

  const _AttachmentTile({
    required this.path,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isImg = _isImagePath(path);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surface,
          child: isImg
              ? ThemeAwareImage(
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _AttachmentIconTile(path: path),
                  ),
                )
              : _AttachmentIconTile(path: path),
        ),
      ),
    );
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
}

/// Widget hiển thị icon cho tệp không phải ảnh
class _AttachmentIconTile extends StatelessWidget {
  final String path;

  const _AttachmentIconTile({required this.path});

  @override
  Widget build(BuildContext context) {
    final name = path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 28,
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
}