import 'package:flutter/material.dart';

import '../../../../app/translate/tl.dart';
import 'settings_card.dart';

class SuperDarkModeCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SuperDarkModeCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0D0D),
            Color(0xFF2D2D2D),
            Color(0xFF888888), // Refraction streak
            Color(0xFF2D2D2D),
            Color(0xFF0D0D0D),
          ],
          stops: [0.0, 0.44, 0.5, 0.56, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 0,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SettingsCard(
        backgroundColor: Colors.transparent,
        child: SwitchListTile(
          title: Text(
            tl('Super Dark Mode'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          subtitle: Text(
            tl('Use deep black for AMOLED displays'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.white.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
