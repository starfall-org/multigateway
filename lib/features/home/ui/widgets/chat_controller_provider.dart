import 'package:flutter/material.dart';
import 'package:multigateway/features/home/controllers/home_controller.dart';

/// InheritedWidget để share ChatController xuống widget tree
class ChatControllerProvider extends InheritedWidget {
  final ChatController controller;

  const ChatControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Lấy controller từ context
  static ChatController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        ChatControllerProvider>();
    assert(provider != null, 'No ChatControllerProvider found in context');
    return provider!.controller;
  }

  /// Lấy controller từ context (nullable)
  static ChatController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        ChatControllerProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(ChatControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}