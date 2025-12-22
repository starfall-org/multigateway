import 'package:flutter/material.dart';
import '../../sys/theme_extensions.dart';

enum SidebarPosition { left, right }

class AppSidebar extends StatelessWidget {
  final Widget child;
  final double width;
  final SidebarPosition position;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const AppSidebar({
    super.key,
    required this.child,
    this.width = 300,
    this.position = SidebarPosition.left,
    this.backgroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _ = backgroundColor ?? theme.scaffoldBackgroundColor;

    final _ =
        borderSide ??
        BorderSide(color: theme.dividerColor.withAlpha(50), width: 1);

    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color:
            (backgroundColor ??
            Theme.of(context).extension<SecondarySurface>()?.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor),
        border: Border(
          left: position == SidebarPosition.right
              ? (borderSide ??
                    Theme.of(
                      context,
                    ).extension<SecondarySurface>()?.borderSide ??
                    BorderSide(
                      color: theme.dividerColor.withAlpha(50),
                      width: 1,
                    ))
              : BorderSide.none,
          right: position == SidebarPosition.left
              ? (borderSide ??
                    Theme.of(
                      context,
                    ).extension<SecondarySurface>()?.borderSide ??
                    BorderSide(
                      color: theme.dividerColor.withAlpha(50),
                      width: 1,
                    ))
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}
