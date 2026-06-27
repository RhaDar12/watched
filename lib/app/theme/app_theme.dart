import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Montserrat',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.cardLight,
          surface: AppColors.surface,
          error: Color(0xFFCF6679),
          onPrimary: AppColors.background,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,

        // AppBar — transparent, no elevation
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTypography.title,
        ),

        // Text
        textTheme: const TextTheme(
          displayLarge: AppTypography.title,
          displayMedium: AppTypography.heading,
          bodyLarge: AppTypography.body,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.small,
          labelLarge: AppTypography.label,
          labelSmall: AppTypography.small,
        ),

        // Elevated Button — pill, white on dark
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            textStyle: AppTypography.button,
            minimumSize:
                const Size(double.infinity, AppDimensions.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.buttonRadius),
            ),
            elevation: 0,
          ),
        ),

        // Outlined Button — pill, white border, transparent bg
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            textStyle: AppTypography.button,
            minimumSize:
                const Size(double.infinity, AppDimensions.buttonHeight),
            side: const BorderSide(color: AppColors.accent, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),

        // TextField — underline style with white line
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: AppDimensions.paddingSm,
          ),
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCF6679), width: 1),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFCF6679), width: 1.5),
          ),
          labelStyle: AppTypography.label,
          hintStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.2,
            color: AppColors.textHint,
          ),
        ),

        // Card — dark gray, no border
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.cardRadius),
          ),
          color: AppColors.card,
          margin: EdgeInsets.zero,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}
