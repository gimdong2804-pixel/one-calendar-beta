import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'providers/planner_provider.dart';
import 'providers/settings_provider.dart';
import 'theme.dart';
import 'widgets/planner_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      title: 'One Calendar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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
