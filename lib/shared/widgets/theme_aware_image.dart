import 'package:flutter/material.dart';

/// Applies a subtle overlay so light/dark themed images remain legible.
class ThemeAwareImage extends StatelessWidget {
  const ThemeAwareImage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);

    return ColorFiltered(
      colorFilter: ColorFilter.mode(overlayColor, BlendMode.overlay),
      child: child,
    );
  }
}
