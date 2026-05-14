import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  DateTime _currentDate = DateTime.now();
  
  List<Todo> get todos => _todos;
  DateTime get currentDate => _currentDate;

  String get _dateKey => '${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}';

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos_$_dateKey');
    if (todosJson != null) {
      final List<dynamic> decoded = json.decode(todosJson);
      _todos = decoded.map((item) => Todo.fromJson(item)).toList();
    } else {
      // 초기 데이터
      _todos = [];
    }
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_todos.map((t) => t.toJson()).toList());
    await prefs.setString('todos_$_dateKey', encoded);
  }

  void changeDate(int daysToAdd) {
    _currentDate = _currentDate.add(Duration(days: daysToAdd));
    _loadTodos();
  }

  void addTodo(String content) {
    if (content.trim().isEmpty) return;
    _todos.add(Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
    ));
    notifyListeners();
    _saveTodos();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index].isCompleted = !_todos[index].isCompleted;
      notifyListeners();
      _saveTodos();
    }
  }

  void removeTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveTodos();
  }

  void reorderTodos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _todos.removeAt(oldIndex);
    _todos.insert(newIndex, item);
    notifyListeners();
    _saveTodos();
  }
}
