import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final Widget? header;
  final List<Widget> items;
  final Widget? footer;

  const AppBottomSheet({super.key, this.header, required this.items, this.footer});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: items),
          ),
          if (footer != null) ...[const Divider(), footer!],
        ],
      ),
    );
  }
}
