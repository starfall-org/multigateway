import 'package:flutter/material.dart';
import 'package:multigateway/features/mcp/presentation/controllers/edit_mcpserver_controller.dart';

/// InheritedWidget để share EditMcpItemController xuống widget tree
class McpControllerProvider extends InheritedWidget {
  final EditMcpItemController controller;

  const McpControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Lấy controller từ context
  static EditMcpItemController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<McpControllerProvider>();
    assert(provider != null, 'No McpControllerProvider found in context');
    return provider!.controller;
  }

  /// Lấy controller từ context (nullable)
  static EditMcpItemController? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<McpControllerProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(McpControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
