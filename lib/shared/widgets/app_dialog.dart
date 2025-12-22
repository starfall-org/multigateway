import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.contentPadding,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget title,
    required Widget content,
    List<Widget>? actions,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        contentPadding: contentPadding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      contentPadding:
          contentPadding ?? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      // Use DialogThemeData.shape from Theme to allow border when SecondaryBackgroundMode.off
    );
  }
}
