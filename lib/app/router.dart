import 'package:flutter/material.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/main/screens/main_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/detail/screens/detail_screen.dart';
import '../data/models/watched_item.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String detail = '/detail';

  /// Fade transition duration for non-navbar page navigations.
  static const Duration _fadeDuration = Duration(milliseconds: 350);

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);
      case main:
        return _fadeRoute(const MainScreen(), settings);
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case register:
        return _fadeRoute(const RegisterScreen(), settings);
      case detail:
        final item = settings.arguments as WatchedItem?;
        return _fadeRoute(DetailScreen(item: item), settings);
      default:
        return _fadeRoute(
          const Scaffold(
            body: Center(child: Text('404 - Halaman tidak ditemukan')),
          ),
          settings,
        );
    }
  }

  /// Creates a PageRouteBuilder with a fade in/out transition.
  static PageRouteBuilder<dynamic> _fadeRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: _fadeDuration,
      reverseTransitionDuration: _fadeDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
