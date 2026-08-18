class TodoItem {
  const TodoItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.priority,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.dueDate,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? notes;
  final String priority;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    notes: json['notes'] as String?,
    priority: json['priority'] as String? ?? 'medium',
    dueDate: json['due_date'] == null
        ? null
        : DateTime.parse(json['due_date'] as String),
    completed: json['completed'] as bool? ?? false,
    completedAt: json['completed_at'] == null
        ? null
        : DateTime.parse(json['completed_at'] as String).toLocal(),
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );
}
