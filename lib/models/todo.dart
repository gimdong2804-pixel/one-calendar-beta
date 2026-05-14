class Todo {
  String id;
  String content;
  bool isCompleted;

  Todo({
    required this.id,
    required this.content,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      content: json['content'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
