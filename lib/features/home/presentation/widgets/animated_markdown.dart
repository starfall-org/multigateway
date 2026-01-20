import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Widget hiển thị Markdown với hiệu ứng fade-in và mở rộng mượt mà
class AnimatedMarkdown extends StatefulWidget {
  final String content;

  const AnimatedMarkdown({
    super.key,
    required this.content,
  });

  @override
  State<AnimatedMarkdown> createState() => _AnimatedMarkdownState();
}

class _AnimatedMarkdownState extends State<AnimatedMarkdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  String? _displayedContent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _displayedContent = widget.content;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _displayedContent = widget.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedSize để mở rộng xuống mượt mà khi nội dung thay đổi
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: FadeTransition(
        opacity: _opacity,
        child: MarkdownBody(
          data: _displayedContent ?? '',
          selectable: true,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.5,
                  height: 1.5,
                ),
            listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15.5,
                ),
          ),
        ),
      ),
    );
  }
}