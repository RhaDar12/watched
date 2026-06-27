import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/spotlight_background.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/database_helper.dart';
import '../../../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseHelper.instance.loginUser(username, password);

    if (user != null && user.id != null) {
      await AuthService.instance.saveSession(user.id!);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Akun tidak ditemukan / Password salah')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SpotlightBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenMargin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),

                  // Login card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 36,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // LOGIN header
                        Text(
                          'LOGIN',
                          style: AppTypography.title.copyWith(
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Username field
                        AppTextField(
                          controller: _usernameController,
                          label: 'Username',
                        ),
                        const SizedBox(height: 24),

                        // Password field
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 36),

                        // Login button
                        AppButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 24),

                        // Register link
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.small.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              children: [
                                const TextSpan(text: 'Belum punya akun? '),
                                TextSpan(
                                  text: 'Daftar',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
