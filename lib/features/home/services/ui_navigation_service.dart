import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/shared/widgets/app_snackbar.dart';

/// Service xử lý các thao tác UI và navigation
class UiNavigationService {
  /// Scroll controller để điều khiển cuộn danh sách tin nhắn
  static void scrollToBottom(ScrollController scrollController) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Kiểm tra xem có đang ở gần cuối danh sách không
  static bool isNearBottom(ScrollController scrollController) {
    if (!scrollController.hasClients) return true;
    final position = scrollController.position;
    return position.pixels >= position.maxScrollExtent - 100;
  }

  /// Copy transcript vào clipboard
  static Future<void> copyTranscriptToClipboard(
    BuildContext context, 
    String transcript,
  ) async {
    if (transcript.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: transcript));

    if (context.mounted) {
      context.showSuccessSnackBar(tl('Transcript copied'));
    }
  }

  /// Copy message content vào clipboard
  static Future<void> copyMessageToClipboard(
    BuildContext context,
    String? messageContent,
  ) async {
    if ((messageContent ?? '').trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: messageContent ?? ''));
    if (context.mounted) {
      context.showSuccessSnackBar(tl('Transcript copied'));
    }
  }

  /// Mở drawer navigation
  static void openDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState?.openDrawer();
  }

  /// Mở end drawer
  static void openEndDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState?.openEndDrawer();
  }

  /// Đóng end drawer
  static void closeEndDrawer(GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState?.closeEndDrawer();
  }
}