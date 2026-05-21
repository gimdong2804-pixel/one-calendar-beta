import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBgBody = Color(0xFFF8FAFC);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  static const Color accentPrimary = Color(0xFF4F46E5);
  static const Color accentSecondary = Color(0xFFEC4899);
  static const Color accentTertiary = Color(0xFF10B981);

  static const Color darkBgBody = Color(0xFF0F172A);
  static const Color darkBgCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  static const Color darkAccentPrimary = Color(0xFF818CF8);
  static const Color darkAccentSecondary = Color(0xFFF472B6);

  static ThemeData lightTheme(bool isSoundEnabled) => _theme(
    brightness: Brightness.light,
    scaffold: lightBgBody,
    surface: lightBgCard,
    primary: accentPrimary,
    secondary: accentSecondary,
    textPrimary: lightTextPrimary,
    textSecondary: lightTextSecondary,
    textMuted: lightTextMuted,
    isSoundEnabled: isSoundEnabled,
  );

  static ThemeData darkTheme(bool isSoundEnabled) => _theme(
    brightness: Brightness.dark,
    scaffold: darkBgBody,
    surface: darkBgCard,
    primary: darkAccentPrimary,
    secondary: darkAccentSecondary,
    textPrimary: darkTextPrimary,
    textSecondary: darkTextSecondary,
    textMuted: darkTextMuted,
    isSoundEnabled: isSoundEnabled,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required bool isSoundEnabled,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        tertiary: accentTertiary,
        surface: surface,
        onSurface: textPrimary,
      ),
      listTileTheme: ListTileThemeData(
        enableFeedback: isSoundEnabled,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          enableFeedback: isSoundEnabled,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: isSoundEnabled,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          enableFeedback: isSoundEnabled,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          enableFeedback: isSoundEnabled,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          enableFeedback: isSoundEnabled,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        enableFeedback: isSoundEnabled,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        enableFeedback: isSoundEnabled,
      ),
      navigationBarTheme: const NavigationBarThemeData(
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      useMaterial3: true,
      fontFamily: 'Pretendard',
      fontFamilyFallback: const [
        'Pretendard',
        'Apple SD Gothic Neo',
        'Malgun Gothic',
        'Segoe UI',
      ],
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1.18,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.55),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.55),
        bodySmall: TextStyle(color: textMuted, fontSize: 12, height: 1.45),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        isDense: true,
        hintStyle: TextStyle(color: textMuted, fontWeight: FontWeight.w500),
      ),
      iconTheme: IconThemeData(color: textSecondary),
      tooltipTheme: const TooltipThemeData(
        triggerMode: TooltipTriggerMode.manual,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension AppThemeColors on BuildContext {
  Color get mutedText => Theme.of(this).brightness == Brightness.dark
      ? AppTheme.darkTextMuted
      : AppTheme.lightTextMuted;

  Color get borderSubtle => Theme.of(this).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.1)
      : const Color(0xFFE2E8F0);

  Color get softInput => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF0F172A).withValues(alpha: 0.62)
      : Colors.white.withValues(alpha: 0.82);
}
