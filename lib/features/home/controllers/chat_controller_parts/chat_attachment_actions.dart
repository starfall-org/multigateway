part of '../chat_controller.dart';

extension ChatViewModelAttachmentActions on ChatController {
  Future<void> pickAttachments(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;

      for (final p in paths) {
        if (!pendingAttachments.contains(p)) {
          pendingAttachments.add(p);
        }
      }
      notify();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tl('Unable to pick files: ${e.toString()}'))),
        );
      }
    }
  }

  Future<void> pickAttachmentsFromGallery(BuildContext context) async {
    try {
      final result = await ImagePicker().pickMultiImage();
      final paths = result.map((e) => e.path).toList();
      if (paths.isEmpty) return;

      for (final p in paths) {
        if (!pendingAttachments.contains(p)) {
          pendingAttachments.add(p);
        }
      }
      notify();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tl('Unable to pick files: ${e.toString()}'))),
        );
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingAttachments.length) return;
    pendingAttachments.removeAt(index);
    notify();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingAttachments
      ..clear()
      ..addAll(attachments);
    notify();
  }

  void openAttachmentsSidebar(List<String> attachments) {
    setInspectingAttachments(attachments);
  }
}
