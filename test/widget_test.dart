import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:one_calendar/main.dart';
import 'package:one_calendar/providers/settings_provider.dart';
import 'package:one_calendar/providers/todo_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => TodoProvider()),
        ],
        child: const OneCalendarApp(),
      ),
    );

    // Verify that the title is present.
    expect(find.text('One Calendar'), findsWidgets);
  });
}
