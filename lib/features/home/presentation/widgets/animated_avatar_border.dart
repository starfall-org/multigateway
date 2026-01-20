import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Widget hiển thị avatar với viền xoay khi đang loading
class AnimatedAvatarBorder extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final double radius;
  final double borderWidth;

  const AnimatedAvatarBorder({
    super.key,
    required this.child,
    this.isAnimating = false,
    this.radius = 18,
    this.borderWidth = 2.5,
  });

  @override
  State<AnimatedAvatarBorder> createState() => _AnimatedAvatarBorderState();
}

class _AnimatedAvatarBorderState extends State<AnimatedAvatarBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedAvatarBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpinningBorderPainter(
            progress: _controller.value,
            color: Theme.of(context).colorScheme.primary,
            borderWidth: widget.borderWidth,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Custom painter để vẽ viền xoay quanh avatar
class _SpinningBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double borderWidth;

  _SpinningBorderPainter({
    required this.progress,
    required this.color,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Vẽ cung xoay (270 độ)
    const sweepAngle = math.pi * 1.5; // 270 degrees
    final startAngle = progress * 2 * math.pi - math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinningBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.borderWidth != borderWidth;
  }
}
