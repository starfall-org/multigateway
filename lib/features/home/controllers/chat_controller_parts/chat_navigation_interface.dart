abstract class ChatNavigationInterface {
  void showSnackBar(String message);

  Future<({String content, List<String> attachments, bool resend})?>
  showEditMessageDialog({
    required String initialContent,
    required List<String> initialAttachments,
  });

  void openDrawer();
  void openEndDrawer();
  void closeEndDrawer();

  String getTranslatedString(String key, {Map<String, String>? namedArgs});
}
