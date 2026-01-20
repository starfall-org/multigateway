import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';

/// Widget hiển thị dropdown cho reasoning content với hiệu ứng streaming
class ReasoningDropdown extends StatefulWidget {
  final String reasoning;
  final bool isStreaming;

  const ReasoningDropdown({
    super.key,
    required this.reasoning,
    this.isStreaming = false,
  });

  @override
  State<ReasoningDropdown> createState() => _ReasoningDropdownState();
}

class _ReasoningDropdownState extends State<ReasoningDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  String? _displayedReasoning;
  bool _isExpanded = false;
  bool _wasStreaming = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _displayedReasoning = widget.reasoning;
    _wasStreaming = widget.isStreaming;
    _isExpanded = widget.isStreaming;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ReasoningDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Cập nhật nội dung khi có thay đổi
    if (widget.reasoning != oldWidget.reasoning) {
      setState(() {
        _displayedReasoning = widget.reasoning;
      });
    }
    
    // Tự động mở khi bắt đầu streaming
    if (widget.isStreaming && !_wasStreaming) {
      setState(() {
        _isExpanded = true;
        _wasStreaming = true;
      });
    }
    
    // Tự động đóng khi kết thúc streaming
    if (!widget.isStreaming && _wasStreaming) {
      setState(() {
        _isExpanded = false;
        _wasStreaming = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withValues(alpha: 0.8),
        );

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8),
        collapsedIconColor: Theme.of(context).iconTheme.color,
        iconColor: Theme.of(context).iconTheme.color,
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 4),
            Text(tl('Reasoning content'), style: style),
          ],
        ),
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            alignment: Alignment.topLeft,
            child: FadeTransition(
              opacity: _opacity,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _displayedReasoning ?? '',
                  style: style,
                  maxLines: widget.isStreaming ? 3 : null,
                  overflow: widget.isStreaming ? TextOverflow.ellipsis : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
