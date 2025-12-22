import 'package:flutter/material.dart';

/// ThemeExtension to expose a "secondary surface" used for dialogs, drawers, and sidebars.
/// - backgroundColor: the surface color
/// - borderSide: optional high-contrast border when mode is Off
class SecondarySurface extends ThemeExtension<SecondarySurface> {
  final Color backgroundColor;
  final BorderSide? borderSide;

  const SecondarySurface({required this.backgroundColor, this.borderSide});

  @override
  SecondarySurface copyWith({Color? backgroundColor, BorderSide? borderSide}) {
    return SecondarySurface(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  @override
  SecondarySurface lerp(ThemeExtension<SecondarySurface>? other, double t) {
    if (other is! SecondarySurface) return this;
    return SecondarySurface(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderSide: _lerpBorder(borderSide, other.borderSide, t),
    );
  }

  static BorderSide? _lerpBorder(BorderSide? a, BorderSide? b, double t) {
    if (a == null && b == null) return null;
    // Treat null as transparent 0-width so lerp works smoothly
    final BorderSide aSide =
        a ?? const BorderSide(color: Colors.transparent, width: 0);
    final BorderSide bSide =
        b ?? const BorderSide(color: Colors.transparent, width: 0);
    return BorderSide.lerp(aSide, bSide, t);
  }
}
