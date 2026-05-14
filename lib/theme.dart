import 'package:flutter/material.dart';

class AppTheme {
  // 라이트 모드 색상
  static const Color lightBgBody = Color(0xFFF8FAFC);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  
  static const Color accentPrimary = Color(0xFF4F46E5);
  static const Color accentSecondary = Color(0xFFEC4899);
  static const Color accentTertiary = Color(0xFF10B981);

  // 다크 모드 색상
  static const Color darkBgBody = Color(0xFF0F172A);
  static const Color darkBgCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);
  
  static const Color darkAccentPrimary = Color(0xFF818CF8);
  static const Color darkAccentSecondary = Color(0xFFF472B6);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBgBody,
      primaryColor: accentPrimary,
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        secondary: accentSecondary,
        surface: lightBgCard,
        onSurface: lightTextPrimary,
        error: Colors.redAccent,
      ),
      fontFamily: 'Pretendard', // 나중에 폰트 추가 예정
      useMaterial3: true,
      cardTheme: const CardThemeData(
        color: lightBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: lightTextPrimary),
        bodyMedium: TextStyle(color: lightTextSecondary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBgBody,
      primaryColor: darkAccentPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkAccentPrimary,
        secondary: darkAccentSecondary,
        surface: darkBgCard,
        onSurface: darkTextPrimary,
        error: Colors.redAccent,
      ),
      fontFamily: 'Pretendard',
      useMaterial3: true,
      cardTheme: const CardThemeData(
        color: darkBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: darkTextPrimary),
        bodyMedium: TextStyle(color: darkTextSecondary),
      ),
    );
  }
}
