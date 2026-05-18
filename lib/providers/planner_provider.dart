import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/planner_data.dart';

enum PlannerPanel { priorities, todos }

class PlannerProvider with ChangeNotifier {
  PlannerProvider() {
    unawaited(_loadForDate(_currentDate));
  }

  DateTime _currentDate = DateTime.now();
  PlannerData _data = PlannerData.defaults();
  PlannerPanel _activePanel = PlannerPanel.priorities;
  SharedPreferences? _prefs;
  Timer? _saveDebounce;
  bool _isLoading = true;
  bool _isSaving = false;

  DateTime get currentDate => _currentDate;
  PlannerData get data => _data;
  PlannerPanel get activePanel => _activePanel;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  int get selectedTodoCount =>
      _data.todos.where((todo) => todo.selected).length;

  String get _storageKey => 'planData_${plannerDateKey(_currentDate)}_flutter';

  Future<void> changeDate(int days) async {
    await saveNow();
    _currentDate = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day + days,
    );
    _activePanel = PlannerPanel.priorities;
    await _loadForDate(_currentDate);
  }

  Future<void> setDate(DateTime date) async {
    await saveNow();
    _currentDate = DateTime(date.year, date.month, date.day);
    _activePanel = PlannerPanel.priorities;
    await _loadForDate(_currentDate);
  }

  void setActivePanel(PlannerPanel panel) {
    if (_activePanel == panel) return;
    _activePanel = panel;
    notifyListeners();
  }

  void togglePriorityTodoPanel() {
    final nextPanel = _activePanel == PlannerPanel.priorities
        ? PlannerPanel.todos
        : PlannerPanel.priorities;
    _activePanel = nextPanel;
    if (nextPanel == PlannerPanel.todos && _data.todos.isEmpty) {
      _data.todos.add(TodoEntry.empty());
      _scheduleSave();
    }
    notifyListeners();
  }

  void updatePriority(int index, String value) {
    if (index < 0 || index >= _data.priorities.length) return;
    _data.priorities[index].text = value;
    _scheduleSave();
  }

  void addPriority() {
    _data.priorities.add(PriorityEntry(id: createPlannerId('prior'), text: ''));
    _scheduleSave(notify: true);
  }

  void removePriority(int index) {
    if (index < 0 || index >= _data.priorities.length) return;
    _data.priorities.removeAt(index);
    _scheduleSave(notify: true);
  }

  void reorderPriorities(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex < 0 || oldIndex >= _data.priorities.length) return;
    if (newIndex < 0 || newIndex > _data.priorities.length) return;
    final item = _data.priorities.removeAt(oldIndex);
    _data.priorities.insert(newIndex, item);
    _scheduleSave(notify: true);
  }

  void updateTimeBlock(int index, {String? time, String? text}) {
    if (index < 0 || index >= _data.timeBlocks.length) return;
    final block = _data.timeBlocks[index];
    if (time != null) block.time = time;
    if (text != null) block.text = text;
    _scheduleSave();
  }

  void addTimeBlock() {
    _data.timeBlocks.add(
      TimeBlock(id: createPlannerId('time'), time: '', text: ''),
    );
    _scheduleSave(notify: true);
  }

  void removeTimeBlock(int index) {
    if (index < 0 || index >= _data.timeBlocks.length) return;
    _data.timeBlocks.removeAt(index);
    _scheduleSave(notify: true);
  }

  void reorderTimeBlocks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    if (oldIndex < 0 || oldIndex >= _data.timeBlocks.length) return;
    if (newIndex < 0 || newIndex > _data.timeBlocks.length) return;
    final item = _data.timeBlocks.removeAt(oldIndex);
    _data.timeBlocks.insert(newIndex, item);
    _scheduleSave(notify: true);
  }

  void addTodo({bool notify = true}) {
    _data.todos.add(TodoEntry.empty());
    _scheduleSave(notify: notify);
  }

  void updateTodo(int index, {String? title, String? note}) {
    if (index < 0 || index >= _data.todos.length) return;
    final todo = _data.todos[index];
    if (title != null) todo.title = title;
    if (note != null) todo.note = note;
    _scheduleSave();
  }

  void toggleTodoSelection(int index, bool selected) {
    if (index < 0 || index >= _data.todos.length) return;
    _data.todos[index].selected = selected;
    _scheduleSave(notify: true);
  }

  void removeTodo(int index) {
    if (index < 0 || index >= _data.todos.length) return;
    _data.todos.removeAt(index);
    _scheduleSave(notify: true);
  }

  void updatePomodoroTitle(int index, String title) {
    if (index < 0 || index >= _data.pomodoros.length) return;
    _data.pomodoros[index].title = title;
    _scheduleSave();
  }

  void togglePomodoroCheck(int row, int col) {
    if (row < 0 || row >= _data.pomodoros.length) return;
    if (col < 0 || col >= _data.pomodoros[row].checks.length) return;
    _data.pomodoros[row].checks[col] = !_data.pomodoros[row].checks[col];
    _scheduleSave(notify: true);
  }

  void updateFeedback(String value) {
    _data.feedback = value;
    _scheduleSave();
  }

  void applyAiExample() {
    _data = PlannerData(
      priorities: [
        PriorityEntry(id: createPlannerId('prior'), text: '수학 기출 2회분 오답까지 끝내기'),
        PriorityEntry(
          id: createPlannerId('prior'),
          text: '영어 지문 12개 분석하고 단어 정리',
        ),
        PriorityEntry(
          id: createPlannerId('prior'),
          text: '오늘 배운 개념 20분 안에 백지 복습',
        ),
      ],
      timeBlocks: [
        TimeBlock(
          id: createPlannerId('time'),
          time: '06:00 - 07:00',
          text: '기상, 가벼운 스트레칭, 전날 오답 훑기',
        ),
        TimeBlock(
          id: createPlannerId('time'),
          time: '07:00 - 12:00',
          text: '수학 집중 학습과 기출 풀이',
        ),
        TimeBlock(
          id: createPlannerId('time'),
          time: '12:00 - 13:00',
          text: '점심시간',
        ),
        TimeBlock(
          id: createPlannerId('time'),
          time: '13:00 - 17:00',
          text: '영어 지문 분석, 단어 암기, 독해 복습',
        ),
        TimeBlock(
          id: createPlannerId('time'),
          time: '18:00 - 22:00',
          text: '약점 과목 보완, 오늘 계획 마감 체크',
        ),
      ],
      todos: [
        TodoEntry(
          id: createPlannerId('todo'),
          title: '오늘 할 일 점검',
          note: '공부 시작 전 핵심 목표 3개를 다시 읽고, 끝난 뒤 체크합니다.',
        ),
      ],
      pomodoros: List.generate(
        6,
        (index) => PomodoroTask(
          id: createPlannerId('pomo'),
          title: index == 0 ? '수학 기출문제 풀이' : '',
          checks: List.filled(8, false),
        ),
      ),
      feedback: '',
    );
    _activePanel = PlannerPanel.priorities;
    _scheduleSave(notify: true);
  }

  Future<void> clearCurrentDate() async {
    _data = PlannerData.defaults();
    _activePanel = PlannerPanel.priorities;
    await saveNow();
    notifyListeners();
  }

  Future<void> saveNow() async {
    _saveDebounce?.cancel();
    await _persist();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    final prefs = await _preferences;
    final key = 'planData_${plannerDateKey(date)}_flutter';
    final raw = prefs.getString(key);
    if (raw == null) {
      _data = PlannerData.defaults();
    } else {
      try {
        final decoded = jsonDecode(raw);
        _data = decoded is Map<String, dynamic>
            ? PlannerData.fromJson(decoded)
            : PlannerData.defaults();
      } catch (_) {
        _data = PlannerData.defaults();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<SharedPreferences> get _preferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  void _scheduleSave({bool notify = false}) {
    if (notify) notifyListeners();
    _isSaving = true;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_persist());
    });
  }

  Future<void> _persist() async {
    final prefs = await _preferences;
    await prefs.setString(_storageKey, jsonEncode(_data.toJson()));
    _isSaving = false;
    notifyListeners();
  }
}
