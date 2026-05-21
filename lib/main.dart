import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/planner_provider.dart';
import 'providers/settings_provider.dart';
import 'services/background_update_service.dart';
import 'theme.dart';
import 'widgets/planner_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 850),
      minimumSize: Size(400, 850),
      center: true,
      title: 'One Calendar',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await BackgroundUpdateService.initialize();
    } catch (e) {
      debugPrint('백그라운드 업데이트 서비스 초기화 실패: $e');
    }
  }

  Intl.defaultLocale = 'ko_KR';
  await initializeDateFormatting('ko_KR');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
      ],
      child: const OneCalendarApp(),
    ),
  );
}

class OneCalendarApp extends StatelessWidget {
  const OneCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeMode = settings.themeMode;
    final isSoundEnabled = settings.isSoundEnabled;

    return MaterialApp(
      title: 'One Calendar',
      theme: AppTheme.lightTheme(isSoundEnabled),
      darkTheme: AppTheme.darkTheme(isSoundEnabled),
      themeMode: themeMode,
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final clamped = scale > 1.08 ? 1.08 : scale;
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(clamped)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const PlannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
