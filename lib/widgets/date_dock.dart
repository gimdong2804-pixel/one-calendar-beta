import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class DateDock extends StatelessWidget {
  const DateDock({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final currentDate = todoProvider.currentDate;
    
    // 요일 가져오기 (예: 목요일)
    final weekdayStr = DateFormat('EEEE', 'ko_KR').format(currentDate);
    // 날짜 가져오기 (예: 05.14)
    final displayDate = '${currentDate.month.toString().padLeft(2, '0')}.${currentDate.day.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 24),
              onPressed: () {
                context.read<TodoProvider>().changeDate(-1);
              },
              color: Theme.of(context).textTheme.bodyLarge?.color,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // 달력 모달 열기 (TODO)
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    weekdayStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    displayDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 24),
              onPressed: () {
                context.read<TodoProvider>().changeDate(1);
              },
              color: Theme.of(context).textTheme.bodyLarge?.color,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
