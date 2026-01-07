import 'package:flutter/material.dart';
import 'package:multigateway/features/settings/controllers/appearance_controller.dart';

/// InheritedWidget để share AppearanceController xuống widget tree
class AppearanceControllerProvider extends InheritedWidget {
  final AppearanceController controller;

  const AppearanceControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Lấy controller từ context
  static AppearanceController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<
        AppearanceControllerProvider>();
    assert(provider != null, 'No AppearanceControllerProvider found in context');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(AppearanceControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}