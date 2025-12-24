import 'package:flutter/material.dart';

class FilesActionSheet extends StatelessWidget {
  final VoidCallback onPickAttachments;
  final VoidCallback? onPickFromGallery;

  const FilesActionSheet({
    super.key,
    required this.onPickAttachments,
    this.onPickFromGallery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Options
            Row(
              children: [
                Expanded(
                  child: _actionTile(
                    context,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    icon: Icons.attach_file,
                    iconColor: theme.colorScheme.primary,
                    label: 'Files',
                    onTap: () {
                      Navigator.pop(context);
                      onPickAttachments();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                if (onPickFromGallery != null)
                  Expanded(
                    child: _actionTile(
                      context,
                      color:
                          theme.colorScheme.secondary.withValues(alpha: 0.1),
                      icon: Icons.photo_library,
                      iconColor: theme.colorScheme.secondary,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        onPickFromGallery?.call();
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required VoidCallback onPickAttachments,
    VoidCallback? onPickFromGallery,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FilesActionSheet(
        onPickAttachments: onPickAttachments,
        onPickFromGallery: onPickFromGallery,
      ),
    );
  }
}
