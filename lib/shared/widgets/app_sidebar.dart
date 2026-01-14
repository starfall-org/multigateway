import 'package:flutter/material.dart';

import 'package:multigateway/app/config/theme.dart';

enum SidebarPosition { left, right }

class AppSidebar extends StatelessWidget {
  final Widget child;
  final double width;
  final SidebarPosition position;
  final Color? backgroundColor;

  const AppSidebar({
    super.key,
    required this.child,
    this.width = 300,
    this.position = SidebarPosition.left,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color:
            (backgroundColor ??
            Theme.of(context).extension<SecondarySurface>()?.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor),
      ),
      child: SafeArea(child: child),
    );
  }
}
