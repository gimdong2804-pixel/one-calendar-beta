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
      extensions: [
        brightness == Brightness.light ? lightAppThemeColors : darkAppThemeColors,
      ],
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
          TargetPlatform.android: OneUIPageTransitionsBuilder(),
          TargetPlatform.iOS: OneUIPageTransitionsBuilder(),
          TargetPlatform.windows: OneUIPageTransitionsBuilder(),
          TargetPlatform.macOS: OneUIPageTransitionsBuilder(),
          TargetPlatform.linux: OneUIPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class OneUIPageTransitionsBuilder extends PageTransitionsBuilder {
  const OneUIPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // One UI 감속 곡선 스타일
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 슬라이드 효과 (오른쪽에서 왼쪽으로)
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curve);

    // 뒤에 깔리는 페이지의 연출
    final secondaryCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 뒤에 깔리는 페이지는 왼쪽으로 부드럽게 약간 밀림
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.25, 0.0),
    ).animate(secondaryCurve);

    return RepaintBoundary(
      child: SlideTransition(
        position: slideOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 페이지 사이의 그림자 (움직일 때만 입체감 부여)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                // 페이지가 완전히 멈추면(1.0) 그림자 렌더링을 생략하여 성능 확보
                if (animation.isCompleted) return child!;
                return SlideTransition(
                  position: slideIn,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 25,
                          spreadRadius: 1,
                          offset: const Offset(-8, 0),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              child: RepaintBoundary(child: child),
            ),
          ],
        ),
      ),
    );
  }
}


class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color mutedText;
  final Color borderSubtle;
  final Color softInput;
  final Color settingsBg;
  final Color settingsGroupBg;
  final Color settingsOnSurface;
  final Color glassShadow;
  final Color updateBg;
  final Color updateDetailBg;
  final Color updateDetailCardBg;
  final Color updateSubText;
  final Color updateBodyText;
  final Color updateDragHandle;
  final Color updateCardBorder;
  final Color updateCardShadow;
  final Color updateProgressTrack;
  final Color updateLogBg;

  const AppThemeColors({
    required this.mutedText,
    required this.borderSubtle,
    required this.softInput,
    required this.settingsBg,
    required this.settingsGroupBg,
    required this.settingsOnSurface,
    required this.glassShadow,
    required this.updateBg,
    required this.updateDetailBg,
    required this.updateDetailCardBg,
    required this.updateSubText,
    required this.updateBodyText,
    required this.updateDragHandle,
    required this.updateCardBorder,
    required this.updateCardShadow,
    required this.updateProgressTrack,
    required this.updateLogBg,
  });

  @override
  AppThemeColors copyWith({
    Color? mutedText,
    Color? borderSubtle,
    Color? softInput,
    Color? settingsBg,
    Color? settingsGroupBg,
    Color? settingsOnSurface,
    Color? glassShadow,
    Color? updateBg,
    Color? updateDetailBg,
    Color? updateDetailCardBg,
    Color? updateSubText,
    Color? updateBodyText,
    Color? updateDragHandle,
    Color? updateCardBorder,
    Color? updateCardShadow,
    Color? updateProgressTrack,
    Color? updateLogBg,
  }) {
    return AppThemeColors(
      mutedText: mutedText ?? this.mutedText,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      softInput: softInput ?? this.softInput,
      settingsBg: settingsBg ?? this.settingsBg,
      settingsGroupBg: settingsGroupBg ?? this.settingsGroupBg,
      settingsOnSurface: settingsOnSurface ?? this.settingsOnSurface,
      glassShadow: glassShadow ?? this.glassShadow,
      updateBg: updateBg ?? this.updateBg,
      updateDetailBg: updateDetailBg ?? this.updateDetailBg,
      updateDetailCardBg: updateDetailCardBg ?? this.updateDetailCardBg,
      updateSubText: updateSubText ?? this.updateSubText,
      updateBodyText: updateBodyText ?? this.updateBodyText,
      updateDragHandle: updateDragHandle ?? this.updateDragHandle,
      updateCardBorder: updateCardBorder ?? this.updateCardBorder,
      updateCardShadow: updateCardShadow ?? this.updateCardShadow,
      updateProgressTrack: updateProgressTrack ?? this.updateProgressTrack,
      updateLogBg: updateLogBg ?? this.updateLogBg,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      softInput: Color.lerp(softInput, other.softInput, t)!,
      settingsBg: Color.lerp(settingsBg, other.settingsBg, t)!,
      settingsGroupBg: Color.lerp(settingsGroupBg, other.settingsGroupBg, t)!,
      settingsOnSurface: Color.lerp(settingsOnSurface, other.settingsOnSurface, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
      updateBg: Color.lerp(updateBg, other.updateBg, t)!,
      updateDetailBg: Color.lerp(updateDetailBg, other.updateDetailBg, t)!,
      updateDetailCardBg: Color.lerp(updateDetailCardBg, other.updateDetailCardBg, t)!,
      updateSubText: Color.lerp(updateSubText, other.updateSubText, t)!,
      updateBodyText: Color.lerp(updateBodyText, other.updateBodyText, t)!,
      updateDragHandle: Color.lerp(updateDragHandle, other.updateDragHandle, t)!,
      updateCardBorder: Color.lerp(updateCardBorder, other.updateCardBorder, t)!,
      updateCardShadow: Color.lerp(updateCardShadow, other.updateCardShadow, t)!,
      updateProgressTrack: Color.lerp(updateProgressTrack, other.updateProgressTrack, t)!,
      updateLogBg: Color.lerp(updateLogBg, other.updateLogBg, t)!,
    );
  }
}

final lightAppThemeColors = AppThemeColors(
  mutedText: AppTheme.lightTextMuted,
  borderSubtle: const Color(0xFFE2E8F0),
  softInput: Colors.white.withValues(alpha: 0.82),
  settingsBg: const Color(0xFFF2F2F7),
  settingsGroupBg: Colors.white,
  settingsOnSurface: const Color(0xFF1C1C1E),
  glassShadow: Colors.black.withValues(alpha: 0.06),
  updateBg: const Color(0xFFF7F7FA),
  updateDetailBg: const Color(0xFFFAFAFD),
  updateDetailCardBg: Colors.white,
  updateSubText: Colors.black45,
  updateBodyText: Colors.black87,
  updateDragHandle: Colors.black26,
  updateCardBorder: Colors.black.withValues(alpha: 0.05),
  updateCardShadow: Colors.black.withValues(alpha: 0.08),
  updateProgressTrack: Colors.black.withValues(alpha: 0.05),
  updateLogBg: Colors.black.withValues(alpha: 0.04),
);

final darkAppThemeColors = AppThemeColors(
  mutedText: AppTheme.darkTextMuted,
  borderSubtle: Colors.white.withValues(alpha: 0.1),
  softInput: const Color(0xFF0F172A).withValues(alpha: 0.62),
  settingsBg: Colors.black,
  settingsGroupBg: const Color(0xFF1C1C1E),
  settingsOnSurface: Colors.white,
  glassShadow: Colors.black.withValues(alpha: 0.28),
  updateBg: Colors.black,
  updateDetailBg: const Color(0xFF121216),
  updateDetailCardBg: const Color(0xFF1C1C22),
  updateSubText: Colors.white54,
  updateBodyText: Colors.white70,
  updateDragHandle: Colors.white24,
  updateCardBorder: Colors.white.withValues(alpha: 0.07),
  updateCardShadow: Colors.black.withValues(alpha: 0.45),
  updateProgressTrack: Colors.white.withValues(alpha: 0.08),
  updateLogBg: Colors.white.withValues(alpha: 0.06),
);

extension AppThemeColorsExt on BuildContext {
  AppThemeColors get colors => Theme.of(this).extension<AppThemeColors>()!;

  Color get mutedText => colors.mutedText;
  Color get borderSubtle => colors.borderSubtle;
  Color get softInput => colors.softInput;
  Color get settingsBg => colors.settingsBg;
  Color get settingsGroupBg => colors.settingsGroupBg;
  Color get settingsOnSurface => colors.settingsOnSurface;
  Color get glassShadow => colors.glassShadow;
  Color get updateBg => colors.updateBg;
  Color get updateDetailBg => colors.updateDetailBg;
  Color get updateDetailCardBg => colors.updateDetailCardBg;
  Color get updateSubText => colors.updateSubText;
  Color get updateBodyText => colors.updateBodyText;
  Color get updateDragHandle => colors.updateDragHandle;
  Color get updateCardBorder => colors.updateCardBorder;
  Color get updateCardShadow => colors.updateCardShadow;
  Color get updateProgressTrack => colors.updateProgressTrack;
  Color get updateLogBg => colors.updateLogBg;
}
