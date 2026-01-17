import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/home/services/file_pick_service.dart';
import 'package:multigateway/features/home/services/gallery_pick_service.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';
import 'package:signals/signals.dart';

/// Controller responsible for attachment management
class AttachmentController {
  final pendingFiles = listSignal<String>([]);
  final inspectingFiles = listSignal<String>([]);

  Future<void> pickFromFiles(BuildContext context) async {
    try {
      filePickService(pendingFiles.value);
      pendingFiles.set([...pendingFiles.value], force: true);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      galleryPickService(pendingFiles.value);
      pendingFiles.set([...pendingFiles.value], force: true);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(tl('Unable to pick files: ${e.toString()}'));
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= pendingFiles.value.length) return;
    pendingFiles.value.removeAt(index);
    pendingFiles.set([...pendingFiles.value], force: true);
  }

  void clearPendingAttachments() {
    pendingFiles.clear();
  }

  void setInspectingAttachments(List<String> attachments) {
    inspectingFiles.value = [...attachments];
  }

  void openFilesDialog(List<String> attachments) {
    setInspectingAttachments(attachments);
  }

  void clearInspectingAttachments() {
    inspectingFiles.clear();
  }

  void dispose() {
    pendingFiles.dispose();
    inspectingFiles.dispose();
  }
}
