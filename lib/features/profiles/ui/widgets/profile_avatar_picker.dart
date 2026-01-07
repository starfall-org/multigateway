import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multigateway/shared/utils/theme_aware_image.dart';

/// Widget để chọn avatar cho profile
class ProfileAvatarPicker extends StatelessWidget {
  final String avatarPath;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    super.key,
    required this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 50,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: avatarPath.isNotEmpty
                  ? ClipOval(
                      child: ThemeAwareImage(
                        child: Image.file(
                          File(avatarPath),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}