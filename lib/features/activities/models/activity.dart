class Activity {
  const Activity({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.startsAt,
    required this.endsAt,
    required this.repeat,
    required this.monitorUsage,
    required this.warnConflicts,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String category;
  final DateTime startsAt;
  final DateTime endsAt;
  final String repeat;
  final bool monitorUsage;
  final bool warnConflicts;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
    endsAt: DateTime.parse(json['ends_at'] as String).toLocal(),
    repeat: json['repeat'] as String? ?? 'Never',
    monitorUsage: json['monitor_usage'] as bool? ?? true,
    warnConflicts: json['warn_conflicts'] as bool? ?? true,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
  );
}
