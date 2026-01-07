import 'package:flutter/material.dart';

/// Widget helper để tạo hiệu ứng overlay cho ảnh theo theme
class ThemeAwareImage extends StatelessWidget {
  final Widget child;

  const ThemeAwareImage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
        BlendMode.overlay,
      ),
      child: child,
    );
  }
}