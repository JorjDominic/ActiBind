import 'package:flutter/material.dart';
import 'package:actibind/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.indigo,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.35),
        bodyMedium: TextStyle(color: AppColors.ink, fontSize: 14, height: 1.35),
        bodySmall: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.3),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: Brightness.dark,
      surface: const Color(0xFF151822),
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0F1118),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF0F1118),
        foregroundColor: Color(0xFFF5F7FF),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Color(0xFFF5F7FF),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF5F7FF),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFF5F7FF),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFE6E8F0),
          fontSize: 15,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFE6E8F0),
          fontSize: 14,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          color: Color(0xFFAEB4C2),
          fontSize: 12,
          height: 1.3,
        ),
      ),
      useMaterial3: true,
    );
  }
}
