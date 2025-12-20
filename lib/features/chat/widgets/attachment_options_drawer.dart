import 'package:flutter/material.dart';

class AttachmentOptionsDrawer extends StatelessWidget {
  final VoidCallback onPickAttachments;
  final VoidCallback? onMicTap;

  const AttachmentOptionsDrawer({
    super.key,
    required this.onPickAttachments,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Attachment options
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.library_add,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              onTap: () {
                Navigator.pop(context);
                onPickAttachments();
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera pick
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.tertiary),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement document pick (allow multiple)
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show the drawer as a modal bottom sheet
  static void show(
    BuildContext context, {
    required VoidCallback onPickAttachments,
    VoidCallback? onMicTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => AttachmentOptionsDrawer(
        onPickAttachments: onPickAttachments,
        onMicTap: onMicTap,
      ),
    );
  }
}
