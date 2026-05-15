import 'package:flutter_test/flutter_test.dart';
import 'package:one_calendar/main.dart';
import 'package:one_calendar/providers/planner_provider.dart';
import 'package:one_calendar/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('One Calendar planner smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ],
        child: const OneCalendarApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('오늘의 핵심 목표'), findsOneWidget);
    expect(find.textContaining('타임 블로킹'), findsOneWidget);
  });
}
