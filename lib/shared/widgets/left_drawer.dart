import 'package:flutter/material.dart';

import 'app_sidebar.dart';

class LeftDrawer extends StatelessWidget {
  final Widget child;
  final double width;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const LeftDrawer({
    super.key,
    required this.child,
    this.width = 300,
    this.backgroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return AppSidebar(
      position: SidebarPosition.left,
      width: width,
      backgroundColor: backgroundColor,
      borderSide: borderSide,
      child: child,
    );
  }
}
