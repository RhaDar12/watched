import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'router.dart';

class App extends StatelessWidget {
  final bool isLoggedIn;
  const App({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watched',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: isLoggedIn ? AppRouter.splash : AppRouter.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
