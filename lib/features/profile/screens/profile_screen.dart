import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/spotlight_background.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/database_helper.dart';
import '../../../data/auth_service.dart';
import '../../main/screens/main_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _filmCount = 0;
  int _seriesCount = 0;
  bool _showLogos = false; // false = KTM, true = UNPAM + SI

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    final user = MainScreen.of(context)?.currentUser;
    if (user != null && user.id != null) {
      final filmCount = await DatabaseHelper.instance
          .getCountByCategory(user.id!, 'Film');
      final seriesCount = await DatabaseHelper.instance
          .getCountByCategory(user.id!, 'Series');

      if (mounted) {
        setState(() {
          _filmCount = filmCount;
          _seriesCount = seriesCount;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final user = MainScreen.of(context)?.currentUser;
    if (user == null || user.id == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      // Save path to SQLite
      await DatabaseHelper.instance.updateProfilePhoto(user.id!, image.path);
      // Reload user in MainScreen to sync avatar
      if (mounted) {
        MainScreen.of(context)?.loadCurrentUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MainScreen.of(context)?.currentUser;
    final avatarPath = user?.profilePhotoPath;
    final username =
        user?.username.toUpperCase().replaceAll(' ', '_') ?? 'GUEST_USER';
    final email = user?.email.toLowerCase() ?? 'guest@watched.app';

    return SpotlightBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenMargin,
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Avatar with glow
              _buildAvatar(avatarPath),
              const SizedBox(height: 16),

              // Username
              Text(
                username,
                style: AppTypography.heading.copyWith(
                  letterSpacing: 4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: AppTypography.small.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // KTM / Logo reveal card
              _buildRevealCard(),
              const SizedBox(height: 28),

              // Stats section
              _buildStats(),
              const SizedBox(height: 32),

              // Logout button
              AppButton(
                text: 'Logout',
                onPressed: () async {
                  await AuthService.instance.clearSession();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),

              // Spacer for nav bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarPath) {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Container(
        width: AppDimensions.avatarLg + 16,
        height: AppDimensions.avatarLg + 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.08),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardLight,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1.5,
            ),
            image: avatarPath != null
                ? DecorationImage(
                    image: FileImage(File(avatarPath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: avatarPath == null
              ? const Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.textHint,
                    size: 40,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // KTM ↔ UNPAM + SI Reveal Card
  // ──────────────────────────────────────────────

  Widget _buildRevealCard() {
    return GestureDetector(
      onTap: () => setState(() => _showLogos = !_showLogos),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: child,
              );
            },
            child: _showLogos ? _buildLogoReveal() : _buildKtmContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildKtmContent() {
    return Image.asset(
      'assets/images/KTM.jpeg',
      key: const ValueKey('ktm'),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, error, stackTrace) {
        return Container(
          color: AppColors.card,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.badge_outlined,
                    color: AppColors.textHint, size: 40),
                const SizedBox(height: 8),
                Text(
                  'KTM Card',
                  style: AppTypography.label.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoReveal() {
    return Container(
      key: const ValueKey('logos'),
      color: AppColors.card,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo UNPAM
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Unpam logo.jpg',
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  'UNPAM',
                  style: AppTypography.small.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40),
            // Logo SI Serang
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Sistem informasi logo.jpg',
                  height: 70,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  'SISTEM INFORMASI',
                  style: AppTypography.small.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.movie_outlined,
            label: 'FILM',
            count: _filmCount,
          ),
        ),
        const SizedBox(width: AppDimensions.gridGutter),
        Expanded(
          child: _buildStatCard(
            icon: Icons.tv_outlined,
            label: 'SERIES',
            count: _seriesCount,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textPrimary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: AppTypography.title.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.small.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
