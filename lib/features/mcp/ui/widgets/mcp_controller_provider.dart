import 'package:flutter/material.dart';
import 'package:multigateway/features/mcp/controllers/edit_mcpserver_controller.dart';

/// InheritedWidget để share EditMcpServerController xuống widget tree
class McpControllerProvider extends InheritedWidget {
  final EditMcpServerController controller;

  const McpControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Lấy controller từ context
  static EditMcpServerController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        McpControllerProvider>();
    assert(provider != null, 'No McpControllerProvider found in context');
    return provider!.controller;
  }

  /// Lấy controller từ context (nullable)
  static EditMcpServerController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        McpControllerProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(McpControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}