class PlannerData {
  PlannerData({
    required this.priorities,
    required this.timeBlocks,
    required this.todos,
    required this.pomodoros,
    required this.feedback,
  });

  final List<String> priorities;
  final List<TimeBlock> timeBlocks;
  final List<TodoEntry> todos;
  final List<PomodoroTask> pomodoros;
  String feedback;

  factory PlannerData.defaults() {
    return PlannerData(
      priorities: [''],
      timeBlocks: [
        TimeBlock(id: createPlannerId('time'), time: '06:00 - 07:00', text: ''),
        TimeBlock(id: createPlannerId('time'), time: '07:00 - 12:00', text: ''),
        TimeBlock(
          id: createPlannerId('time'),
          time: '12:00 - 13:00',
          text: '점심시간',
        ),
        TimeBlock(id: createPlannerId('time'), time: '13:00 - 17:00', text: ''),
        TimeBlock(id: createPlannerId('time'), time: '18:00 - 22:00', text: ''),
      ],
      todos: const [],
      pomodoros: List.generate(
        6,
        (index) => PomodoroTask(
          id: createPlannerId('pomo'),
          title: '',
          checks: List.filled(8, false),
        ),
      ),
      feedback: '',
    );
  }

  factory PlannerData.fromJson(Map<String, dynamic> json) {
    final priorities = _stringList(json['priors']);
    final timeBlocks = _objectList(
      json['timeBlocks'],
    ).map(TimeBlock.fromJson).toList(growable: true);
    final todos = _objectList(
      json['todos'],
    ).map(TodoEntry.fromJson).toList(growable: true);
    final pomodoroTitles = _stringList(json['pomos']);
    final pomodoroChecks = _boolList(json['pomoCbs']);
    final pomodorosFromObjects = _objectList(
      json['pomodoros'],
    ).map(PomodoroTask.fromJson).toList(growable: true);

    final pomodoros = pomodorosFromObjects.isNotEmpty
        ? pomodorosFromObjects
        : List.generate(6, (row) {
            final start = row * 8;
            final checks = List.generate(
              8,
              (col) => start + col < pomodoroChecks.length
                  ? pomodoroChecks[start + col]
                  : false,
            );
            return PomodoroTask(
              id: createPlannerId('pomo'),
              title: row < pomodoroTitles.length ? pomodoroTitles[row] : '',
              checks: checks,
            );
          });

    while (pomodoros.length < 6) {
      pomodoros.add(
        PomodoroTask(
          id: createPlannerId('pomo'),
          title: '',
          checks: List.filled(8, false),
        ),
      );
    }

    return PlannerData(
      priorities:
          priorities.isEmpty || priorities.every((item) => item.trim().isEmpty)
          ? ['']
          : priorities,
      timeBlocks: timeBlocks.isEmpty
          ? PlannerData.defaults().timeBlocks
          : timeBlocks,
      todos: todos,
      pomodoros: pomodoros.take(6).toList(growable: true),
      feedback: json['feedback'] is String ? json['feedback'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priors': priorities,
      'timeBlocks': timeBlocks.map((block) => block.toJson()).toList(),
      'todos': todos.map((todo) => todo.toJson()).toList(),
      'pomos': pomodoros.map((task) => task.title).toList(),
      'pomoCbs': pomodoros.expand((task) => task.checks).toList(),
      'pomodoros': pomodoros.map((task) => task.toJson()).toList(),
      'feedback': feedback,
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

class TimeBlock {
  TimeBlock({required this.id, required this.time, required this.text});

  final String id;
  String time;
  String text;

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['id'] is String ? json['id'] as String : createPlannerId('time'),
      time: json['time'] is String ? json['time'] as String : '',
      text: json['text'] is String ? json['text'] as String : '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'time': time, 'text': text};
}

class TodoEntry {
  TodoEntry({
    required this.id,
    required this.title,
    required this.note,
    this.selected = false,
  });

  final String id;
  String title;
  String note;
  bool selected;

  factory TodoEntry.empty() {
    return TodoEntry(id: createPlannerId('todo'), title: '', note: '');
  }

  factory TodoEntry.fromJson(Map<String, dynamic> json) {
    return TodoEntry(
      id: json['id'] is String ? json['id'] as String : createPlannerId('todo'),
      title: json['title'] is String ? json['title'] as String : '',
      note: json['note'] is String
          ? json['note'] as String
          : json['html'] is String
          ? _stripHtml(json['html'] as String)
          : json['text'] is String
          ? json['text'] as String
          : '',
      selected: json['selected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'note': note};
}

class PomodoroTask {
  PomodoroTask({required this.id, required this.title, required this.checks});

  final String id;
  String title;
  List<bool> checks;

  factory PomodoroTask.fromJson(Map<String, dynamic> json) {
    final checks = _boolList(json['checks']);
    return PomodoroTask(
      id: json['id'] is String ? json['id'] as String : createPlannerId('pomo'),
      title: json['title'] is String ? json['title'] as String : '',
      checks: List.generate(
        8,
        (index) => index < checks.length ? checks[index] : false,
      ),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'checks': checks};
}

String createPlannerId(String prefix) {
  _plannerIdSequence += 1;
  final now = DateTime.now().microsecondsSinceEpoch;
  return '${prefix}_${now}_$_plannerIdSequence';
}

int _plannerIdSequence = 0;

String plannerDateKey(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

List<String> _stringList(Object? value) {
  if (value is! List) return [];
  return value.map((item) => item?.toString() ?? '').toList(growable: true);
}

List<bool> _boolList(Object? value) {
  if (value is! List) return [];
  return value.map((item) => item == true).toList(growable: true);
}

List<Map<String, dynamic>> _objectList(Object? value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: true);
}

String _stripHtml(String value) {
  return value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();
}
