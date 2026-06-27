import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

/// Floating pill-shaped bottom navigation bar with 3 icons:
/// Home (left), Plus/Add (center with glow), Profile (right).
///
/// Features:
/// - Sliding pill indicator behind the active item (easeInOutBack, 300ms)
/// - Radial gradient glow on every active tab
/// - Scale tap feedback (0.88×, 120ms) on all items
/// - ValueKey on icons to prevent ghost/double rendering
///
/// [currentIndex] — 0=Home, 1=Plus, 2=Profile
/// [disabledIndices] — indices to render as grayed-out (e.g. on auth screens)
/// [onTap] — callback with tapped index
class WatchedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final List<int> disabledIndices;
  final ValueChanged<int>? onTap;

  const WatchedBottomNavBar({
    super.key,
    required this.currentIndex,
    this.disabledIndices = const [],
    this.onTap,
  });

  @override
  State<WatchedBottomNavBar> createState() => _WatchedBottomNavBarState();
}

class _WatchedBottomNavBarState extends State<WatchedBottomNavBar> {
  int? _pressedIndex;

  double _indicatorLeftPosition(double navbarWidth) {
    final sectionWidth = navbarWidth / 3;
    const indicatorWidth = 24.0;
    return sectionWidth * widget.currentIndex +
        (sectionWidth - indicatorWidth) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppDimensions.navBarBottomPadding +
            MediaQuery.of(context).padding.bottom,
        left: 60,
        right: 60,
      ),
      child: Container(
        height: AppDimensions.navBarHeight,
        decoration: BoxDecoration(
          color: AppColors.navBar.withValues(alpha: AppColors.navBarOpacity),
          borderRadius: BorderRadius.circular(AppDimensions.navBarRadius),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final navbarWidth = constraints.maxWidth;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Sliding underline indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  bottom: 12,
                  left: _indicatorLeftPosition(navbarWidth),
                  child: Container(
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: Colors.white,
                    ),
                  ),
                ),

                // Nav items row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                      ),
                    ),
                    Expanded(
                      child: _buildCenterItem(),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = widget.currentIndex == index;
    final isDisabled = widget.disabledIndices.contains(index);

    return GestureDetector(
      onTap: isDisabled ? null : () => widget.onTap?.call(index),
      onTapDown:
          isDisabled ? null : (_) => setState(() => _pressedIndex = index),
      onTapUp:
          isDisabled ? null : (_) => setState(() => _pressedIndex = null),
      onTapCancel: () => setState(() => _pressedIndex = null),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        key: ValueKey('nav_${index}_$isActive'), // ROOT KEY — prevent ghost/double render
        child: Center(
          child: AnimatedScale(
            scale: _pressedIndex == index ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive && !isDisabled
                    ? RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.20),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                      )
                    : null,
                boxShadow: isActive && !isDisabled
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isDisabled
                    ? AppColors.textDisabled
                    : isActive
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem() {
    final isActive = widget.currentIndex == 1;
    final isDisabled = widget.disabledIndices.contains(1);

    return GestureDetector(
      onTap: isDisabled ? null : () => widget.onTap?.call(1),
      onTapDown:
          isDisabled ? null : (_) => setState(() => _pressedIndex = 1),
      onTapUp:
          isDisabled ? null : (_) => setState(() => _pressedIndex = null),
      onTapCancel: () => setState(() => _pressedIndex = null),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        key: ValueKey('nav_1_$isActive'),
        width: 48,
        height: 48,
        child: Center(
          child: AnimatedScale(
            scale: _pressedIndex == 1 ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive && !isDisabled
                    ? RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.20),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                      )
                    : null,
                boxShadow: isActive && !isDisabled
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.add,
                color: isDisabled
                    ? AppColors.textDisabled
                    : isActive
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
