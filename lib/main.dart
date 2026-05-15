import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/settings_provider.dart';
import 'providers/todo_provider.dart';
import 'widgets/date_dock.dart';
import 'widgets/todo_list_view.dart';
import 'widgets/settings_modal.dart';

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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = settingsProvider.themeMode == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            children: [
              // 상단 바 (DateDock + 설정 아이콘들)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DateDock(),
                  Row(
                    children: [
                      _buildTopIconButton(
                        context,
                        icon: isDark ? Icons.dark_mode : Icons.light_mode,
                        onPressed: () {
                          settingsProvider.setThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildTopIconButton(
                        context,
                        icon: settingsProvider.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                        text: '0', // 예시
                        onPressed: () {
                          settingsProvider.setSoundEnabled(!settingsProvider.isSoundEnabled);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildTopIconButton(
                        context,
                        icon: Icons.settings,
                        onPressed: () {
                          showSettingsModal(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 메인 카드 영역
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 타이틀 헤더
                        const Text(
                          '🔥 오늘의 핵심 목표 (Top 3)',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '오늘 반드시 해결할 핵심 목표를 먼저 정리해보세요.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 할 일 목록 열기 버튼
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '할 일 목록 열기 ↗',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 할 일 목록 위젯
                        const Expanded(child: TodoListView()),
                        const SizedBox(height: 16),
                        // 하단 버튼 그룹
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Text('🤖', style: TextStyle(fontSize: 16)),
                                label: const Text('AI 어시스턴트', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Text('✨', style: TextStyle(fontSize: 16)),
                                label: const Text('AI가 짠 예시 보기', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981), // Green
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // 전체 초기화
                                },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('전체 초기화', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade100,
                                  foregroundColor: Colors.grey.shade800,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconButton(BuildContext context, {required IconData icon, String? text, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)),
                if (text != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
