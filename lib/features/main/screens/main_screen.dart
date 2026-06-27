import 'dart:io';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../home/screens/home_screen.dart';
import '../../add/screens/add_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../data/models/user.dart';
import '../../../data/database_helper.dart';
import '../../../data/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();

  // Helper method to access MainScreenState from child tabs to trigger avatar sync
  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }
}

class MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  User? currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (mounted) {
        setState(() {
          currentUser = user;
          _isLoadingUser = false;
        });
      }
    } else {
      // Not logged in, go to login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Fade transition between pages — no slide flash
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
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
            child: IndexedStack(
              key: ValueKey<int>(_currentIndex),
              index: _currentIndex,
              children: const [
                HomeScreen(),
                AddScreen(),
                ProfileScreen(),
              ],
            ),
          ),

          // Bottom nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: WatchedBottomNavBar(
              currentIndex: _currentIndex,
              onTap: onTabTapped,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Drawer
  // ──────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background.withValues(alpha: 0.95),
      width: 280,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Divider(
              color: AppColors.border.withValues(alpha: 0.15),
              height: 1,
            ),
            _buildDrawerItem(Icons.home_rounded, 'Home', 0),
            _buildDrawerItem(Icons.add_circle_outline, 'Add Film/Series', 1),
            _buildDrawerItem(Icons.person_outline, 'Profile', 2),
            const Spacer(),
            _buildDrawerItem(
              Icons.logout_rounded,
              'Logout',
              -1,
              isLogout: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final user = currentUser;
    final avatarPath = user?.profilePhotoPath;
    final username =
        user?.username.toUpperCase().replaceAll(' ', '_') ?? 'GUEST';
    final email = user?.email.toLowerCase() ?? 'guest@watched.app';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardLight,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              image: avatarPath != null
                  ? DecorationImage(
                      image: FileImage(File(avatarPath)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarPath == null
                ? const Icon(Icons.person, color: AppColors.textHint, size: 24)
                : null,
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTypography.small.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String label,
    int index, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? const Color(0xFFCF6679) : AppColors.textPrimary,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTypography.body.copyWith(
          color: isLogout ? const Color(0xFFCF6679) : AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        if (isLogout) {
          AuthService.instance.clearSession();
          Navigator.of(context).pushReplacementNamed('/login');
        } else {
          onTabTapped(index);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      hoverColor: AppColors.cardLight,
    );
  }
}
