import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      context.read<TodoProvider>().addTodo(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    final todos = todoProvider.todos;

    return Column(
      children: [
        // 목록
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent, // 드래그 시 배경 투명하게
            ),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              itemCount: todos.length,
              onReorder: (oldIndex, newIndex) {
                todoProvider.reorderTodos(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _buildTodoItem(context, todo, index, todoProvider);
              },
            ),
          ),
        ),
        
        // 입력창 (구버전 스타일에는 명시적 입력창이 없거나 따로 있지만, 기능 유지를 위해 하단에 심플하게 배치)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '새로운 목표 추가...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                  onPressed: _addTodo,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodoItem(BuildContext context, Todo todo, int index, TodoProvider provider) {
    return Container(
      key: ValueKey(todo.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 드래그 아이콘
            const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            // 인덱스 번호 (보라색)
            Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Text(
                todo.content,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            // 삭제 버튼
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              onPressed: () => provider.removeTodo(todo.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
