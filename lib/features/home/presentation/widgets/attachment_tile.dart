import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multigateway/shared/utils/theme_aware_image.dart';

/// Widget hiển thị một tệp đính kèm trong sidebar
class AttachmentTile extends StatelessWidget {
  final String path;

  const AttachmentTile({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final name = path.split('/').last;
    int sizeBytes = 0;
    
    try {
      sizeBytes = File(path).lengthSync();
    } catch (_) {}
    
    final sizeText = _formatBytes(sizeBytes);
    final isImg = _isImagePath(path);

    Widget leading;
    if (isImg) {
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: Theme.of(context).colorScheme.surface,
          child: ThemeAwareImage(
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => _FallbackIcon(),
            ),
          ),
        ),
      );
    } else {
      leading = _FallbackIcon();
    }

    return ListTile(
      leading: leading,
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: sizeBytes > 0 ? Text(sizeText) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: () {
        // Preview action can be added later
      },
    );
  }

  String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double v = bytes.toDouble();
    while (v >= 1024 && i < sizes.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(decimals)} ${sizes[i]}';
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

/// Icon mặc định cho các tệp không phải ảnh
class _FallbackIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.insert_drive_file,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}