import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/settings_provider.dart';
import 'providers/todo_provider.dart';
import 'widgets/global_fabs.dart';
import 'widgets/date_dock.dart';
import 'widgets/todo_list_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const OneCalendarApp(),
    ),
  );
}

class OneCalendarApp extends StatelessWidget {
  const OneCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'One Calendar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.themeMode,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('One Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 설정 모달 띄우기 (나중에 구현)
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Column(
            children: [
              SizedBox(height: 20),
              // 헤더 (우선순위 카드 등 나중에 추가 가능)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '오늘의 할 일',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(child: TodoListView()),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: DateDock(),
          ),
        ],
      ),
      floatingActionButton: const GlobalFabs(),
    );
  }
}
