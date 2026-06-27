class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Watched';
  static const String appVersion = '1.0.0';

  // Timing
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const Duration timeoutDuration = Duration(seconds: 30);
}

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
