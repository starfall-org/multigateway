import 'package:flutter/material.dart';
import 'package:multigateway/app/translate/tl.dart';
import 'package:multigateway/features/profiles/ui/widgets/profile_avatar_picker.dart';
import 'package:multigateway/features/profiles/ui/widgets/profile_controller_provider.dart';
import 'package:multigateway/shared/widgets/custom_text_field.dart';

/// Tab thông tin chung của profile
class ProfileGeneralTab extends StatelessWidget {
  const ProfileGeneralTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileControllerProvider.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
            ProfileAvatarPicker(
              avatarPath: controller.avatarController.text,
              onTap: () => controller.pickImage(context),
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: controller.nameController,
              label: tl('AI Profile Name'),
              prefixIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: 24),

            // System Prompt
            CustomTextField(
              controller: controller.promptController,
              label: tl('System Prompt'),
              maxLines: 6,
              prefixIcon: Icons.description_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
