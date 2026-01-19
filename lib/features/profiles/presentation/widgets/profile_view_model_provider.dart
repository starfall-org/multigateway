import 'package:flutter/material.dart';
import 'package:multigateway/features/profiles/presentation/controllers/edit_profile_controller.dart';

/// InheritedWidget để cung cấp EditProfileController cho các widget con
/// mà không cần truyền qua constructor
class ProfileControllerProvider extends InheritedWidget {
  final EditProfileController controller;

  const ProfileControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Lấy controller từ context
  static EditProfileController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ProfileControllerProvider>();
    assert(provider != null, 'ProfileControllerProvider not found in context');
    return provider!.controller;
  }

  /// Lấy controller từ context (nullable)
  static EditProfileController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProfileControllerProvider>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(ProfileControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
