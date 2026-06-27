import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable full-screen spotlight background widget.
/// Uses the Backgorund.png asset as the spotlight overlay on top
/// of the near-black base color.
class SpotlightBackground extends StatelessWidget {
  final Widget child;

  const SpotlightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Spotlight image — full screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/Backgorund.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              opacity: const AlwaysStoppedAnimation(0.7),
            ),
          ),
          // Content
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
