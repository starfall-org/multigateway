import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Controller responsible for attachment management
class AttachmentController extends ChangeNotifier {
  final List<String> pendingAttachments = [];
  final List<String> inspectingAttachments = [];

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
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
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
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingAttachments.length) return;
    pendingAttachments.removeAt(index);
    notifyListeners();
  }

  void clearPendingAttachments() {
    pendingAttachments.clear();
    notifyListeners();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingAttachments
      ..clear()
      ..addAll(attachments);
    notifyListeners();
  }

  void openFilesDialog(List<String> attachments) {
    setInspectingAttachments(attachments);
  }

  void clearInspectingAttachments() {
    inspectingAttachments.clear();
    notifyListeners();
  }
}
