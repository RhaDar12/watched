import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.instance.isLoggedIn();
  runApp(App(isLoggedIn: isLoggedIn));
}
