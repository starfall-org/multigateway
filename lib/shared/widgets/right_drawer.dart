import 'package:flutter/material.dart';

import 'app_sidebar.dart';

class RightDrawer extends StatelessWidget {
  final Widget child;
  final double width;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const RightDrawer({
    super.key,
    required this.child,
    this.width = 300,
    this.backgroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return AppSidebar(
      position: SidebarPosition.right,
      width: width,
      backgroundColor: backgroundColor,
      borderSide: borderSide,
      child: child,
    );
  }
}
