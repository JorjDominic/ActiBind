class Routine {
  const Routine({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.startMinutes,
    required this.endMinutes,
    required this.activeDays,
    required this.startsOn,
    required this.endsOn,
    required this.active,
    required this.monitorUsage,
    required this.warnConflicts,
  });

  final String id;
  final String userId;
  final String name;
  final String category;
  final int startMinutes;
  final int endMinutes;
  final Set<int> activeDays;
  final DateTime startsOn;
  final DateTime? endsOn;
  final bool active;
  final bool monitorUsage;
  final bool warnConflicts;

  bool occursOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startsOn.year, startsOn.month, startsOn.day);
    final end = endsOn == null
        ? null
        : DateTime(endsOn!.year, endsOn!.month, endsOn!.day);
    return active &&
        !day.isBefore(start) &&
        (end == null || !day.isAfter(end)) &&
        activeDays.contains(day.weekday);
  }

  DateTime startsAt(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
    startMinutes ~/ 60,
    startMinutes % 60,
  );

  DateTime endsAt(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
    endMinutes ~/ 60,
    endMinutes % 60,
  );

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    startMinutes: _parseTime(json['start_time'] as String),
    endMinutes: _parseTime(json['end_time'] as String),
    activeDays: (json['active_days'] as List)
        .cast<num>()
        .map((e) => e.toInt())
        .toSet(),
    startsOn: DateTime.parse(json['starts_on'] as String),
    endsOn: json['ends_on'] == null
        ? null
        : DateTime.parse(json['ends_on'] as String),
    active: json['active'] as bool? ?? true,
    monitorUsage: json['monitor_usage'] as bool? ?? true,
    warnConflicts: json['warn_conflicts'] as bool? ?? true,
  );

  static int _parseTime(String value) {
    final parts = value.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class RoutineOccurrence {
  const RoutineOccurrence({
    required this.routineId,
    required this.scheduledDate,
    required this.status,
  });

  final String routineId;
  final DateTime scheduledDate;
  final String status;

  factory RoutineOccurrence.fromJson(Map<String, dynamic> json) =>
      RoutineOccurrence(
        routineId: json['routine_id'] as String,
        scheduledDate: DateTime.parse(json['scheduled_date'] as String),
        status: json['status'] as String,
      );
}
