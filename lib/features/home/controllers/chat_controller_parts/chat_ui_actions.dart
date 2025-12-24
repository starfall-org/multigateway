part of '../chat_controller.dart';

extension ChatViewModelUIActions on ChatController {
  void scrollToBottom() {
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

  bool isNearBottom() {
    if (!scrollController.hasClients) return true;
    final position = scrollController.position;
    // Considered near bottom if within 100 pixels of the max extent
    return position.pixels >= position.maxScrollExtent - 100;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void openEndDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  void closeEndDrawer() {
    scaffoldKey.currentState?.closeEndDrawer();
  }
}
