import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Montserrat';

  // Title — 22pt, wght 700
  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Heading — 18pt, wght 600
  static const TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  // Body — 14pt, wght 400
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  // Label — 12pt, wght 300
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Small — 10pt, wght 300
  static const TextStyle small = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Nav label
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.0,
    color: AppColors.textPrimary,
  );

  // Terminal / monospace style for profile
  static const TextStyle terminal = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.8,
    color: AppColors.textPrimary,
    height: 2.0,
  );
}
