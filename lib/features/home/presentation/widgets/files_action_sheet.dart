import 'package:flutter/material.dart';
import 'package:multigateway/shared/widgets/bottom_sheet.dart';

class FilesActionSheet extends StatelessWidget {
  final VoidCallback onPickAttachments;
  final VoidCallback? onPickFromGallery;
  final ScrollController scrollController;

  const FilesActionSheet({
    super.key,
    required this.onPickAttachments,
    this.onPickFromGallery,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
    CustomBottomSheet.show(
      context,
      initialChildSize: 0.32,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      builder: (ctx, scrollController) => FilesActionSheet(
        onPickAttachments: onPickAttachments,
        onPickFromGallery: onPickFromGallery,
        scrollController: scrollController,
      ),
    );
  }
}
