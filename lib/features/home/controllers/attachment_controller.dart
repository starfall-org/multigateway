import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/services/file_pick_service.dart';
import 'package:multigateway/features/home/services/gallery_pick_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Controller responsible for attachment management
class AttachmentController extends ChangeNotifier {
  final List<String> pendingFiles = [];
  final List<String> inspectingFiles = [];

  Future<void> pickFromFiles(BuildContext context) async {
    try {
      filePickService(pendingFiles);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      galleryPickService(pendingFiles);
      notifyListeners();
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingFiles.length) return;
    pendingFiles.removeAt(index);
    notifyListeners();
  }

  void clearPendingAttachments() {
    pendingFiles.clear();
    notifyListeners();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingFiles
      ..clear()
      ..addAll(attachments);
    notifyListeners();
  }

  void openFilesDialog(List<String> attachments) {
    setInspectingAttachments(attachments);
  }

  void clearInspectingAttachments() {
    inspectingFiles.clear();
    notifyListeners();
  }
}
